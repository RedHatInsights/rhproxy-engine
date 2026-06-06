#!/bin/bash
#
# rhproxy-engine Entrypoint

set -e

export RHPROXY_NAME="Insights proxy"

echo "Initializing ${RHPROXY_NAME} version ${RHPROXY_ENGINE_VERSION} ..."
echo ""

# Create the self-signed certificates if not provided.
"${APP_ROOT}/etc/rhproxy_init_certs.sh"

# Let's make sure the download folder is created
mkdir -p "${APP_DOWNLOAD}"

NGINX_CONFIG_ENV_VARS="\
\$RHPROXY_WEB_SERVER_PORT,\
\$RHPROXY_WEB_SERVER_DISABLE\
"

envsubst "${NGINX_CONFIG_ENV_VARS}" < "${NGINX_CONF_PATH}.template" > "${NGINX_CONF_PATH}"

if [ "${RHPROXY_DEBUG_CONFIG}" = "1" ]; then
    echo
    echo "----------------------------------------------------------------------"
    echo "Environment Variables:"
    echo
    env | sort
    echo
    echo "----------------------------------------------------------------------"
    echo "Nginx configuration file: ${NGINX_CONF_PATH}"
    echo
    cat "${NGINX_CONF_PATH}"
    echo
fi

echo "Starting ${RHPROXY_NAME} version ${RHPROXY_ENGINE_VERSION} ..."

if [ "${RHPROXY_DISABLE}" != "1" ]; then
    SQUID_CONFIG_ENV_VARS="\
\$RHPROXY_SERVICE_PORT,\
\$RHPROXY_DNS_SERVER,\
\$SQUID_CONF_DIR\
"

    # If the rhproxy service provides us with server lists, convert them to squid
    # dstdomains format (one domain per line, comments and blanks stripped).
    function server_to_dstdomains() {
      if [ -s "${1}" ]; then
        grep -Ev "^#|^$|^[ \t]*$" "${1}" | sort -u
      fi
    }

    if [ -s "${APP_RHPROXY_ENV}/redhat.servers" ]; then
      server_to_dstdomains "${APP_RHPROXY_ENV}/redhat.servers" > "${SQUID_CONF_DIR}/redhat.dstdomains"
    fi

    if [ -s "${APP_RHPROXY_ENV}/epel.servers" ]; then
      server_to_dstdomains "${APP_RHPROXY_ENV}/epel.servers" > "${SQUID_CONF_DIR}/epel.dstdomains"
    fi

    if [ -s "${APP_RHPROXY_ENV}/mirror.servers" ]; then
      server_to_dstdomains "${APP_RHPROXY_ENV}/mirror.servers" > "${SQUID_CONF_DIR}/mirror.dstdomains"
    fi

    envsubst "${SQUID_CONFIG_ENV_VARS}" < "${SQUID_CONF_DIR}/squid.conf.template" > "${SQUID_CONF_DIR}/squid.conf"

    if [ "${RHPROXY_DEBUG_CONFIG}" = "1" ]; then
        echo
        echo "----------------------------------------------------------------------"
        echo "Squid configuration file: ${SQUID_CONF_DIR}/squid.conf"
        echo
        cat "${SQUID_CONF_DIR}/squid.conf"
        echo
        echo "----------------------------------------------------------------------"
        echo "RedHat destination domains: ${SQUID_CONF_DIR}/redhat.dstdomains"
        echo
        cat "${SQUID_CONF_DIR}/redhat.dstdomains"
        echo
        echo "----------------------------------------------------------------------"
        echo "EPEL destination domains: ${SQUID_CONF_DIR}/epel.dstdomains"
        echo
        cat "${SQUID_CONF_DIR}/epel.dstdomains"
        echo
        echo "----------------------------------------------------------------------"
        echo "Optional mirror destination domains: ${SQUID_CONF_DIR}/mirror.dstdomains"
        echo
        cat "${SQUID_CONF_DIR}/mirror.dstdomains"
        echo
    fi

    squid -N -f "${SQUID_CONF_DIR}/squid.conf" &
    SQUID_PID=$!
    trap 'kill ${SQUID_PID} 2>/dev/null; wait ${SQUID_PID} 2>/dev/null' EXIT
fi

"${NGINX_BASE}/usr/sbin/nginx" -g "daemon off;"
