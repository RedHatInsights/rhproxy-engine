#!/bin/bash
#
# Insights-Proxy Entrypoint

set -e

export INSIGHTS_PROXY_NAME="Insights-Proxy"

# Create the self-signed certificates if not provided.
${APP_ROOT}/etc/insights_init_certs.sh

# Create/Override the servers list handes by the Insights-Proxy
if [ -n "${INSIGHTS_PROXY_SERVERS_FILE}" -a -s "${INSIGHTS_PROXY_SERVERS_FILE}" ]; then
    SERVERS_LIST="$(cat ${INSIGHTS_PROXY_SERVERS_FILE} | egrep -v "^#|^$|^[ \t]*$" | tr '\n' ' ')"
    if [ -n "${SERVERS_LIST}" ]; then
        export INSIGHTS_PROXY_SERVER_NAMES="${SERVERS_LIST}"
    fi
fi

envsubst "\$INSIGHTS_PROXY_SERVICE_PORT, \$INSIGHTS_PROXY_SERVER_NAMES, \$INSIGHTS_PROXY_DNS_SERVER" \
    < ${NGINX_CONF_PATH}.template \
    > ${NGINX_CONF_PATH}

if [ "${INSIGHTS_PROXY_DEBUG_CONFIG}" = "1" ]; then
    echo
    echo "----------------------------------------------------------------------"
    echo "Environment Variables:"
    echo
    env | sort
    echo
    echo "----------------------------------------------------------------------"
    echo "Nginx configuation file: ${NGINX_CONF_PATH}"
    echo
    cat ${NGINX_CONF_PATH}
    echo
fi

echo "Starting ${INSIGHTS_PROXY_NAME} ..."
${NGINX_BASE}/usr/sbin/nginx -g "daemon off;"
