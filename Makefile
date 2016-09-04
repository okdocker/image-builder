export ROCKER_OPTIONS
TARGET ?= all

.PHONY: all push debian nginx python

all: debian nginx python

push:
	TARGET=push make all

debian:
	(cd debian; make $(TARGET))

nginx: debian
	(cd nginx; make $(TARGET))

python: debian
	(cd python; make $(TARGET))

