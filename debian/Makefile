DEBIAN_RELEASE ?= jessie
ROCKER_OPTIONS ?=

.PHONY: all
all: jessie stretch

.PHONY: push
push:
	ROCKER_OPTIONS=--push make all

.PHONY: debian
debian:
	rocker build -var debian_release=$(DEBIAN_RELEASE) $(ROCKER_OPTIONS) .

.PHONY: jessie
jessie: debian

.PHONY: stretch
stretch:
	DEBIAN_RELEASE=$@ make debian
