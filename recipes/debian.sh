echo "Container setup: debian"
echo "---------------------"

set -e -x

apt-get update

apt-get install -y build-essential curl git sudo vim
apt-get install -y libxml2-dev libxslt-dev libz-dev

echo 'alias l="ls -lsah"' >> /root/.bashrc

