echo "Container setup: python"
echo "-----------------------"

set -e -x

apt-get install -y python$PYTHON_VERSION python$PYTHON_VERSION-dev
curl https://bootstrap.pypa.io/get-pip.py | python$PYTHON_VERSION

