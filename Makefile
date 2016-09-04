export ROCKER_OPTIONS

.PHONY: all debian nginx

all: debian nginx

debian:
	(cd debian; make all)

nginx: debian
	(cd nginx; make all)
