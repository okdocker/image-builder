PWD=$(shell pwd)
VENDOR=okdocker
BUILD_VOLUMES= -v /dev/null:/etc/apt/apt.conf.d/docker-clean \
               -v ~/.cache/okdocker/apt-cache:/var/cache/apt \
               -v ~/.cache/okdocker/root-cache:/root/.cache \
               -v ~/.cache/okdocker/wheelhouse:/tmp/wheelhouse \
               -v ~/.cache/okdocker/build:/tmp/build \
               -v $(PWD):/build
PYTHON_VERSION ?= 2.7
OK=.okdocker

.PHONY: all
all:
	make $(OK)/python2.7
	make $(OK)/python3.4
	make $(OK)/python3.5
	make $(OK)/nginx

.PHONY: push
push: all
	docker push $(VENDOR)/debian-jessie
	docker push $(VENDOR)/python2.7
	docker push $(VENDOR)/python3.4
	docker push $(VENDOR)/python3.5
	docker push $(VENDOR)/nginx

$(OK):
	mkdir $(OK)

$(OK)/debian-jessie: $(OK)
	docker run -it -v $(PWD)/recipes/debian.sh:/setup.sh $(BUILD_VOLUMES) debian:jessie /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/debian-stretch: $(OK)
	docker run -t -v $(PWD)/recipes/debian.sh:/setup.sh $(BUILD_VOLUMES) debian:stretch /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/python2.7: $(OK)/debian-jessie
	docker run -t -e PYTHON_VERSION=$(PYTHON_VERSION) -v $(PWD)/recipes/python.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/debian-jessie:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/python3.4: $(OK)/debian-jessie
	docker run -t -e PYTHON_VERSION=$(PYTHON_VERSION) -v $(PWD)/recipes/python.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/debian-jessie:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/python3.5: $(OK)/debian-stretch
	docker run -t -e PYTHON_VERSION=3.5 -v $(PWD)/recipes/python.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/debian-stretch:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)


$(OK)/nginx-base: $(OK)/debian-jessie
	docker run -it -v $(PWD)/recipes/nginx.sh:/setup.sh $(BUILD_VOLUMES) $(VENDOR)/debian-jessie:latest /bin/sh /setup.sh
	docker ps -ql --no-trunc > $@
	docker commit `cat $@` $(subst $(OK),$(VENDOR),$@)

$(OK)/nginx: $(OK)/nginx-base
	docker build --no-cache -f recipes/nginx.dockerfile -t $(subst $(OK),$(VENDOR),$@) recipes

