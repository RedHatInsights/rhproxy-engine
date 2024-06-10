FROM registry.access.redhat.com/ubi9/nginx-124

# Add Insights-Proxy sources
ADD app/etc/nginx/nginx.conf "${NGINX_CONF_PATH}"

CMD nginx -g "daemon off;"
