echo "Container setup: nginx"
echo "----------------------"

set -e -x

# Add sources
apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key
echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list

apt-get -y update
apt-get -y install dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget vim
apt-get -y build-dep nginx-full

NGINX_VERSION=1.8.0
NGINX_VERSION_DEBIAN=$NGINX_VERSION-1~jessie
NGINX_PAGESPEED_VERSION=1.9.32.6
BUILD_DIR=/tmp/build/nginx-$NGINX_VERSION-ps-$NGINX_PAGESPEED_VERSION

mkdir -p $BUILD_DIR
(
    cd $BUILD_DIR
    rm -rf nginx-${NGINX_VERSION}
    apt-get source nginx=${NGINX_VERSION_DEBIAN}
    wget https://dl.google.com/dl/page-speed/psol/$NGINX_PAGESPEED_VERSION.tar.gz -O $BUILD_DIR/psol-$NGINX_PAGESPEED_VERSION.tar.gz
    wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NGINX_PAGESPEED_VERSION}-beta.zip -O $BUILD_DIR/pagespeed-$NGINX_PAGESPEED_VERSION.zip
    mkdir -p nginx-${NGINX_VERSION}/debian/modules
    (
        cd nginx-$NGINX_VERSION/debian/modules
        unzip $BUILD_DIR/pagespeed-$NGINX_PAGESPEED_VERSION.zip
        mv ngx_pagespeed-release-$NGINX_PAGESPEED_VERSION-beta ngx_pagespeed-$NGINX_PAGESPEED_VERSION
    )
    (
        cd nginx-$NGINX_VERSION/debian/modules/ngx_pagespeed-$NGINX_PAGESPEED_VERSION
        tar xzf $BUILD_DIR/psol-$NGINX_PAGESPEED_VERSION.tar.gz
    )

    sed "/LDFLAGS /a WITH_PAGESPEED := --add-module=debian/modules/ngx_pagespeed-$NGINX_PAGESPEED_VERSION" -i nginx-$NGINX_VERSION/debian/rules
    sed '/$(WITH_SPDY) \\/a 		$(WITH_PAGESPEED) \\' -i nginx-$NGINX_VERSION/debian/rules

    (
        cd nginx-$NGINX_VERSION
        dpkg-buildpackage -b
    )

    dpkg -i `ls *.deb | grep -v debug`
)

