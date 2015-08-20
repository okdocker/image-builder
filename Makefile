PWD=$(shell pwd)
VENDOR=okdocker
BUILD_VOLUMES= -v /dev/null:/etc/apt/apt.conf.d/docker-clean \
               -v /mnt/sda1/volumes/apt-archives:/var/cache/apt/archives \
               -v /mnt/sda1/volumes/pip-cache:/tmp/pip-cache \
               -v /mnt/sda1/volumes/wheelhouse:/tmp/wheelhouse \
               -v /mnt/sda1/volumes/build:/tmp/build \
               -v $(PWD):/build
PYTHON_VERSION ?= 2.7
OK=.okdocker

all:
	PYTHON_VERSION=2.7 make $(OK)/python
	PYTHON_VERSION=3.4 make $(OK)/python

push: all
	docker push $(VENDOR)/base
	docker push $(VENDOR)/python2.7
	docker push $(VENDOR)/python3.4

$(OK):
	mkdir $(OK)

$(OK)/base: $(OK)
	docker run -t -v $(PWD)/recipes/base.sh:/setup.sh $(BUILD_VOLUMES) debian:8 /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/python$(PYTHON_VERSION): $(OK)/base
	docker run -t -e PYTHON_VERSION=$(PYTHON_VERSION) -v $(PWD)/recipes/python.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/base:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/nginx-base: $(OK)/base
	docker run -t -e PYTHON_VERSION=$(PYTHON_VERSION) -v $(PWD)/recipes/nginx.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/base:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/nginx: $(OK)/nginx-base
	docker build -f recipes/nginx.dockerfile -t $(subst $(OK),$(VENDOR),$@) recipes

$(OK)/python: $(OK)/python$(PYTHON_VERSION)


