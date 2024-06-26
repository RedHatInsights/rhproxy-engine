FROM registry.access.redhat.com/ubi9-minimal as base

# Let's declare where we're installing nginx
ENV APP_ROOT=/opt/app-root

ENV NGINX_VERSION="1.24.0"
ENV NGINX_USER="nginx"
ENV NGINX_GROUP="nginx"
ENV NGINX_UID="1001"
ENV NGINX_GID="1001"
ENV NGINX_BASE=${APP_ROOT}/nginx
ENV NGINX_DEFAULT_CONF_PATH=${NGINX_BASE}/etc/nginx.default.d
ENV NGINX_PERL_MODULE_PATH=${NGINX_BASE}/etc/perl
ENV NGINX_CONF_PATH=${NGINX_BASE}/etc/nginx/nginx.conf
ENV NGINX_CONFIGURATION_PATH=${NGINX_BASE}/etc/nginx.d
ENV NGINX_LOG_PATH=/var/log/nginx

ENV NGINX_USER_HOME=${APP_ROOT}/src

WORKDIR ${NGINX_USER_HOME}

RUN mkdir ${NGINX_BASE}
RUN microdnf install -y\
      zlib \
      libaio \
      openssl \
      shadow-utils \
      procps-ng \
      less \
      util-linux \
      vim

# Build nginx with the http_proxy_connect
FROM base as build

RUN microdnf install -y\
      gcc \
      gcc-c++ \
      kernel-headers \
      make \
      zlib-devel \
      pcre-devel \
      tar \
      wget \
      git \
      patch \
      openssl-devel \
      libxml2-devel \
      libxslt-devel \
      gd-devel \
      perl

RUN mkdir -p /opt/app-root/src \
      && cd /opt/app-root/src \
      && git clone https://github.com/chobits/ngx_http_proxy_connect_module \
      && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xfz nginx-${NGINX_VERSION}.tar.gz \
      && cd nginx-${NGINX_VERSION} \
      && patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch \
      && CLIENT_BODY_TEMP_PATH=${NGINX_BASE}/var/lib/nginx/tmp/client_body \
      && HTTP_PROXY_TEMP_PATH=${NGINX_BASE}/var/lib/nginx/tmp/proxy \
      && HTTP_FASTCGI_TEMP_PATH=${NGINX_BASE}/var/lib/nginx/tmp/fastcgi \
      && HTTP_UWSGI_TEMP_PATH=${NGINX_BASE}/var/lib/nginx/tmp/uwsgi \
      && HTTP_SCGI_TEMP_PATH=${NGINX_BASE}/var/lib/nginx/tmp/scgi \
      && ./configure --prefix=${NGINX_BASE}/usr/share/nginx --sbin-path=${NGINX_BASE}/usr/sbin/nginx \
	    --modules-path=${NGINX_BASE}/usr/lib64/nginx/modules \
	    --conf-path=${NGINX_BASE}/etc/nginx/nginx.conf \
	    --error-log-path=${NGINX_LOG_PATH}/error.log \
	    --http-log-path=${NGINX_LOG_PATH}/access.log \
	    --http-client-body-temp-path=${CLIENT_BODY_TEMP_PATH} \
	    --http-proxy-temp-path=${HTTP_PROXY_TEMP_PATH} \
	    --http-fastcgi-temp-path=${HTTP_FASTCGI_TEMP_PATH} \
	    --http-uwsgi-temp-path=${HTTP_UWSGI_TEMP_PATH} \
	    --http-scgi-temp-path=${HTTP_SCGI_TEMP_PATH} \
	    --pid-path=${NGINX_BASE}/run/nginx.pid \
	    --lock-path=${NGINX_BASE}/run/lock/subsys/nginx \
	    --user=${NGINX_USER} \
	    --group=${NGINX_GROUP} \
	    --with-compat \
	    --with-debug \
	    --with-file-aio \
	    --with-http_addition_module \
	    --with-http_auth_request_module \
	    --with-http_dav_module \
	    --with-http_degradation_module \
	    --with-http_flv_module \
	    --with-http_gunzip_module \
	    --with-http_gzip_static_module \
	    --with-http_image_filter_module=dynamic \
	    --with-http_mp4_module \
	    --with-http_perl_module=dynamic \
	    --with-http_random_index_module \
	    --with-http_realip_module \
	    --with-http_secure_link_module \
	    --with-http_slice_module \
	    --with-http_ssl_module \
	    --with-http_stub_status_module \
	    --with-http_sub_module \
	    --with-http_v2_module \
	    --with-http_xslt_module=dynamic \
	    --with-mail=dynamic \
	    --with-mail_ssl_module \
	    --with-openssl-opt=enable-ktls \
	    --with-pcre \
	    --with-pcre-jit \
	    --with-stream=dynamic \
	    --with-stream_realip_module \
	    --with-stream_ssl_module \
	    --with-stream_ssl_preread_module \
	    --with-threads \
	    --add-dynamic-module="/opt/app-root/src/ngx_http_proxy_connect_module" \
      && mkdir -p ${CLIENT_BODY_TEMP_PATH} ${HTTP_PROXY_TEMP_PATH} ${HTTP_FASTCGI_TEMP_PATH} ${HTTP_UWSGI_TEMP_PATH} ${HTTP_SCGI_TEMP_PATH} \
      && make \
      && make install

# Build image
FROM base as final

# Let's make sure NGINX access and error logs go to stdout and stderr.
RUN mkdir -p ${NGINX_LOG_PATH} \
      && touch ${NGINX_LOG_PATH}/access.log \
      && touch ${NGINX_LOG_PATH}/error.log \
      && ln -sf /dev/stdout ${NGINX_LOG_PATH}/access.log \
      && ln -sf /dev/stderr ${NGINX_LOG_PATH}/error.log

# Setup the user's environment
ENV HOME=${NGINX_USER_HOME}
RUN groupadd --gid ${NGINX_GID} ${NGINX_GROUP} \
      && useradd --uid ${NGINX_UID} --gid ${NGINX_GROUP} --groups root --shell /bin/bash --home-dir ${NGINX_USER_HOME} --create-home ${NGINX_USER}

# Let's copy the built nginx
COPY --from=build ${NGINX_BASE} ${NGINX_BASE}

# Add Insights-Proxy sources:
ADD app/etc/nginx/nginx.conf ${NGINX_CONF_PATH}
ADD app/etc/*.sh ${APP_ROOT}/etc/

# Copy and set the Insights-Proxy entrypoint:
COPY app/entrypoint.sh ${APP_ROOT}/.

# Let's have nginx own the app
USER 0
RUN chown -R ${NGINX_USER}:${NGINX_GROUP} ${APP_ROOT}
# Note: --pid-path and --lock-path above are not honored.
RUN chown ${NGINX_USER}:root /run /run/lock
RUN chmod 775 /run /run/lock
USER ${NGINX_UID}

# Exposing the Insights Proxy port 3128
EXPOSE 3128

CMD ["/bin/bash", "/opt/app-root/entrypoint.sh"]
