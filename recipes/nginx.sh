echo "Container setup: nginx"
echo "----------------------"

set -e -x

# Add sources
apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key
echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list

apt-get -y update
apt-get -y install dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget vim
apt-get -y build-dep nginx

NGINX_VERSION=1.11.2
NGINX_VERSION_DEBIAN=$NGINX_VERSION-1~jessie
NGINX_PAGESPEED_VERSION=1.11.33.2
BUILD_DIR=/tmp/build/nginx-$NGINX_VERSION-ps-$NGINX_PAGESPEED_VERSION

mkdir -p $BUILD_DIR
(
    cd $BUILD_DIR

    # get nginx
    if [ ! -f $BUILD_DIR/nginx-${NGINX_VERSION} ]; then
      apt-get source nginx=${NGINX_VERSION_DEBIAN}
    fi
    # get psol
    if [ ! -f $BUILD_DIR/psol-$NGINX_PAGESPEED_VERSION.tar.gz ]; then
      wget https://dl.google.com/dl/page-speed/psol/$NGINX_PAGESPEED_VERSION.tar.gz -O $BUILD_DIR/psol-$NGINX_PAGESPEED_VERSION.tar.gz
    fi
    # get pagespeed
    if [ ! -f $BUILD_DIR/pagespeed-$NGINX_PAGESPEED_VERSION.zip ]; then
      wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NGINX_PAGESPEED_VERSION}-beta.zip -O $BUILD_DIR/pagespeed-$NGINX_PAGESPEED_VERSION.zip
    fi

    # build in /tmp to avoid docker on mac filesystem problems
    rm -rf /tmp/nginx-$NGINX_VERSION
    mv $BUILD_DIR/nginx-$NGINX_VERSION /tmp/nginx-$NGINX_VERSION

    mkdir -p /tmp/nginx-$NGINX_VERSION/debian/modules
    (
        cd /tmp/nginx-$NGINX_VERSION/debian/modules
        if [ ! -f ngx_pagespeed-$NGINX_PAGESPEED_VERSION ]; then
          unzip $BUILD_DIR/pagespeed-$NGINX_PAGESPEED_VERSION.zip
          rm -rf ngx_pagespeed-$NGINX_PAGESPEED_VERSION
          mv ngx_pagespeed-release-$NGINX_PAGESPEED_VERSION-beta ngx_pagespeed-$NGINX_PAGESPEED_VERSION
        fi
    )
    (
        cd /tmp/nginx-$NGINX_VERSION/debian/modules/ngx_pagespeed-$NGINX_PAGESPEED_VERSION
        tar xzf $BUILD_DIR/psol-$NGINX_PAGESPEED_VERSION.tar.gz
    )

    if [ `grep WITH_PAGESPEED /tmp/nginx-$NGINX_VERSION/debian/rules | wc -l` -eq 0 ]; then
      sed "/LDFLAGS /a WITH_PAGESPEED := --add-module=debian/modules/ngx_pagespeed-$NGINX_PAGESPEED_VERSION" -i /tmp/nginx-$NGINX_VERSION/debian/rules
      sed '/$(WITH_HTTP2) \\/a 		$(WITH_PAGESPEED) \\' -i /tmp/nginx-$NGINX_VERSION/debian/rules
    fi

    (
        cd /tmp/nginx-$NGINX_VERSION
        dpkg-buildpackage -b
    )

    # move away from /tmp
    mv /tmp/nginx*.deb $BUILD_DIR
    mv /tmp/nginx*.changes $BUILD_DIR
    rm -rf /tmp/nginx-$NGINX_VERSION

    dpkg -i `ls *.deb | grep -v debug`
)

