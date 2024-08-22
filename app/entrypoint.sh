#!/bin/bash
#
# rhproxy-engine Entrypoint

set -e

export RHPROXY_NAME="Insights Proxy"

# Create the self-signed certificates if not provided.
${APP_ROOT}/etc/rhproxy_init_certs.sh

# Let's make sure the download folder is created
mkdir -p ${APP_DOWNLOAD}

CONFIG_ENV_VARS="\
\$RHPROXY_SERVICE_PORT,\
\$RHPROXY_SERVER_NAMES,\
\$RHPROXY_DNS_SERVER,\
\$RHPROXY_DISABLE,\
\$RHPROXY_WEB_SERVER_PORT,\
\$RHPROXY_WEB_SERVER_DISABLE\
"

envsubst "${CONFIG_ENV_VARS}" < ${NGINX_CONF_PATH}.template > ${NGINX_CONF_PATH}

if [ "${RHPROXY_DEBUG_CONFIG}" = "1" ]; then
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

echo "Starting ${RHPROXY_NAME} ..."
${NGINX_BASE}/usr/sbin/nginx -g "daemon off;"
