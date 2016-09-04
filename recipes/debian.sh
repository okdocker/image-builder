echo "Container setup: debian"
echo "---------------------"

set -e -x

apt-get update
apt-get install -y curl git sudo libxml2-dev libxslt-dev libz-dev

echo 'alias l="ls -lsah"' >> /root/.bashrc

rm -rf /var/lib/apt/*
