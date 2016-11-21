DEBIAN_RELEASE ?= jessie

ROCKER ?= $(shell [ -x $(GOPATH)/bin/rocker ] && echo $(GOPATH)/bin/rocker || which rocker)
ROCKER_OPTIONS ?=
ROCKER_VARIABLES ?= -var debian_release=$(DEBIAN_RELEASE)

.PHONY: all
all: jessie stretch

.PHONY: push
push:
	ROCKER_OPTIONS=--push make all

.PHONY: debian
debian:
	$(ROCKER) build $(ROCKER_VARIABLES) $(ROCKER_OPTIONS) .

.PHONY: jessie
jessie: debian

.PHONY: stretch
stretch:
	DEBIAN_RELEASE=$@ make debian
