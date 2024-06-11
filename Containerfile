FROM registry.access.redhat.com/ubi9/nginx-124

# The HTTP and HTTPS ports exposed:
EXPOSE 8080
EXPOSE 8443

# Add Insights-Proxy sources:
ADD app/etc/nginx/nginx.conf ${NGINX_CONF_PATH}
ADD app/etc/*.sh ${APP_ROOT}/etc/

# Copy and set the Insights-Proxy entrypoint:
COPY app/entrypoint.sh ${APP_ROOT}/.
CMD ["/bin/bash", "/opt/app-root/entrypoint.sh"]
