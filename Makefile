
UBI_VERSION = 9
UBI_IMAGE = "registry.access.redhat.com/ubi$(UBI_VERSION)"
UBI_MINIMAL_IMAGE = $(shell grep "^FROM .*ubi$(UBI_VERSION)-minimal.* as base" Containerfile | awk '{print $$2;}')
RPM_LOCKFILE_IMAGE = "localhost/rpm-lockfile-update"
NGINX_VERSION = $(shell grep "ENV NGINX_VERSION=" Containerfile | sed -n 's/.*="\(.*\)"/\1/p')
PROXY_CONNECT_VERSION = $(shell grep "ENV PROXY_CONNECT_MODULE_VERSION=" Containerfile | sed -n 's/.*="\(.*\)"/\1/p')
RHPROXY_CONTAINER_TAG ?= rhproxy-engine

all:	help

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help              show this help message"
	@echo "  build             build the container image for the $(RHPROXY_CONTAINER_TAG)"
	@echo "  update-lockfiles  Update ubi.repo and rpms.lock files based on the container base image"
	@echo "  update-sources    update the sources built in $(RHPROXY_CONTAINER_TAG) with:"
	@echo "                    - NGINX v$(NGINX_VERSION)"
	@echo "                    - HTTP Proxy Connect Module v$(PROXY_CONNECT_VERSION)"

build:
	podman build \
		-t $(RHPROXY_CONTAINER_TAG) .

update-lockfiles:
	podman pull $(UBI_MINIMAL_IMAGE)
	podman run -it $(UBI_MINIMAL_IMAGE) cat /etc/yum.repos.d/ubi.repo | \
		sed 's/ubi-$(UBI_VERSION)-codeready-builder-\([[:alnum:]-]*rpms\)/codeready-builder-for-ubi-$(UBI_VERSION)-$$basearch-\1/g' | \
		sed 's/ubi-$(UBI_VERSION)-\([[:alnum:]-]*rpms\)/ubi-$(UBI_VERSION)-for-$$basearch-\1/g' | \
		sed 's/\r$$//' > ubi.repo
	podman pull $(UBI_IMAGE)
	curl https://raw.githubusercontent.com/konflux-ci/rpm-lockfile-prototype/refs/heads/main/Containerfile | \
	  podman build -t $(RPM_LOCKFILE_IMAGE) --build-arg BASE_IMAGE=$(UBI_IMAGE) -
	podman run -w /workdir --rm -v ${PWD}:/workdir:Z $(RPM_LOCKFILE_IMAGE):latest \
	  --image $(UBI_MINIMAL_IMAGE) --outfile=/workdir/rpms.lock.yaml rpms.in.yaml

update-sources:
	@mkdir -p src tar; \
	cd tar; \
	echo "Getting NGINX $(NGINX_VERSION) source ..."; \
	wget -q "https://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz" \
	  -O nginx-$(NGINX_VERSION).tar.gz; \
	echo "Getting HTTP Proxy connect module $(PROXY_CONNECT_VERSION) source ..."; \
	wget -q "https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/tags/v$(PROXY_CONNECT_VERSION).tar.gz" \
	  -O http-proxy-connect-module-$(PROXY_CONNECT_VERSION).tar.gz; \
	cd ../src; \
	echo "Extracting NGINX $(NGINX_VERSION) source ..."; \
	tar xfz ../tar/nginx-$(NGINX_VERSION).tar.gz; \
	echo "Extracting HTTP Proxy connect module $(PROXY_CONNECT_VERSION) source ..."; \
	tar xfz ../tar/http-proxy-connect-module-$(PROXY_CONNECT_VERSION).tar.gz \
	  --exclude='.github'; \
	cd nginx-$(NGINX_VERSION); \
	patch -p1 < ../ngx_http_proxy_connect_module-$(PROXY_CONNECT_VERSION)/patch/proxy_connect_rewrite_102101.patch

