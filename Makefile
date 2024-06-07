
INSIGHTS_PROXY_CONTAINER_TAG ?= insights-proxy

all:	help

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help      show this help message"
	@echo "  build     build the container image for the insights-proxy"

build:
	podman build \
		-t $(INSIGHTS_PROXY_CONTAINER_TAG) .

