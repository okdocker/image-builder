DEBIAN_RELEASE ?= jessie
PYTHON_VERSION ?= 2.7
ROCKER_OPTIONS ?=

.PHONY: all
all: python2.7 python3.4 python3.5

.PHONY: push
push:
	ROCKER_OPTIONS=--push make all

.PHONY: python
python:
	rocker build -var debian_release=$(DEBIAN_RELEASE) -var python_version=$(PYTHON_VERSION) $(ROCKER_OPTIONS) .

.PHONY: python2.7
python2.7:
	PYTHON_VERSION=2.7 DEBIAN_RELEASE=jessie make python

.PHONY: python3.4
python3.4:
	PYTHON_VERSION=3.4 DEBIAN_RELEASE=jessie make python

.PHONY: python3.5
python3.5:
	PYTHON_VERSION=3.5 DEBIAN_RELEASE=stretch make python

