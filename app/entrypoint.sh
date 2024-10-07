#!/bin/bash
#
# rhproxy-engine Entrypoint

set -e

export RHPROXY_NAME="Insights Proxy"

# Create the self-signed certificates if not provided.
"${APP_ROOT}/etc/rhproxy_init_certs.sh"

# Let's make sure the download folder is created
mkdir -p "${APP_DOWNLOAD}"

CONFIG_ENV_VARS="\
\$RHPROXY_SERVICE_PORT,\
\$RHPROXY_DNS_SERVER,\
\$RHPROXY_DISABLE,\
\$RHPROXY_WEB_SERVER_PORT,\
\$RHPROXY_WEB_SERVER_DISABLE\
"

# If the rhproxy services provides us with servers configuration files, let's
# import those and create the server_names config files needed by NGINX.
function server_to_server_names() {
  if [ -s "${1}" ]; then
    cat "${1}" \
    | egrep -v "^#|^$|^[ \t]*$" \
    | sort -u \
    | sed -e 's/^/server_name /g' -e 's/$/;/g'
  fi
}

if [ -s "${APP_RHPROXY_ENV}/redhat.servers" ]; then
  server_to_server_names "${APP_RHPROXY_ENV}/redhat.servers" > "${RHPROXY_CONF_DIR}/redhat.server_names"
fi

if [ -s "${APP_RHPROXY_ENV}/epel.servers" ]; then
  server_to_server_names "${APP_RHPROXY_ENV}/epel.servers" > "${RHPROXY_CONF_DIR}/epel.server_names"
fi

if [ -s "${APP_RHPROXY_ENV}/mirror.servers" ]; then
  server_to_server_names "${APP_RHPROXY_ENV}/mirror.servers" > "${RHPROXY_CONF_DIR}/mirror.server_names"
fi

envsubst "${CONFIG_ENV_VARS}" < "${NGINX_CONF_PATH}.template" > "${NGINX_CONF_PATH}"

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
    cat "${NGINX_CONF_PATH}"
    echo
    echo "----------------------------------------------------------------------"
    echo "RedHat server names: ${RHPROXY_CONF_DIR}/redhat.server_names"
    echo
    cat "${RHPROXY_CONF_DIR}/redhat.server_names"
    echo
    echo "----------------------------------------------------------------------"
    echo "EPEL server names: ${RHPROXY_CONF_DIR}/epel.server_names"
    echo
    cat "${RHPROXY_CONF_DIR}/epel.server_names"
    echo
    echo "----------------------------------------------------------------------"
    echo "Optional mirror server names: ${RHPROXY_CONF_DIR}/mirror.server_names"
    echo
    cat "${RHPROXY_CONF_DIR}/mirror.server_names"
    echo
fi

echo "Starting ${RHPROXY_NAME} ..."
"${NGINX_BASE}/usr/sbin/nginx" -g "daemon off;"
