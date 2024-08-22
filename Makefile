
RHPROXY_CONTAINER_TAG ?= rhproxy-engine

all:	help

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help      show this help message"
	@echo "  build     build the container image for the rhproxy-engine"

build:
	podman build \
		-t $(RHPROXY_CONTAINER_TAG) .

