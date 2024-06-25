#!/bin/bash
#
# Insights-Proxy Entrypoint

set -e

# Initialize Insights-Proxy environment variables if not defined.
source ${APP_ROOT}/etc/env_init.sh

# Create the self-signed certificates if not provided.
${APP_ROOT}/etc/insights_init_certs.sh

echo "Starting ${INSIGHTS_PROXY_NAME} ..."
${NGINX_BASE}/usr/sbin/nginx -g "daemon off;"
