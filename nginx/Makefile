NGINX_VERSION ?= 1.11.6
NGINX_VERSION_DEBIAN ?= $(NGINX_VERSION)-1~jessie
NGINX_PAGESPEED_VERSION ?= 1.11.33.4

ROCKER ?= $(shell [ -x $(GOPATH)/bin/rocker ] && echo $(GOPATH)/bin/rocker || which rocker)
ROCKER_OPTIONS ?=
ROCKER_VARIABLES ?= -var nginx_version=$(NGINX_VERSION) \
                    -var nginx_version_debian=$(NGINX_VERSION_DEBIAN) \
                    -var nginx_pagespeed_version=$(NGINX_PAGESPEED_VERSION)

.PHONY: all
all: nginx

.PHONY: push
push:
	ROCKER_OPTIONS=--push make all

.PHONY: nginx
nginx:
	$(ROCKER) build $(ROCKER_VARIABLES) $(ROCKER_OPTIONS) .

