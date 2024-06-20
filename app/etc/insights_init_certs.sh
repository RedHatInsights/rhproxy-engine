#!/bin/bash
#
# Create the self signed sertificates for the proxy if not included.

set -e

# Let's make sure our certificates directory exists.
CERTS_PATH="${APP_ROOT}/certs"
mkdir -p ${CERTS_PATH}

if ([ -f "${CERTS_PATH}/server.key" ] && [ -f "${CERTS_PATH}/server.crt" ]); then
    echo "Using ${INSIGHTS_PROXY_NAME} certificates ..."
    openssl rsa -in "${CERTS_PATH}/server.key" -check
    openssl x509 -in "${CERTS_PATH}/server.crt" -text -noout
elif [ ! -f "${CERTS_PATH}/server.key" ] && [ ! -f "${CERTS_PATH}/server.crt" ]; then
    echo "Creating ${INSIGHTS_PROXY_NAME} certificates ..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${CERTS_PATH}/server.key" \
        -out "${CERTS_PATH}/server.crt" \
        -subj "/C=US/ST=Raleigh/L=Raleigh/O=IT/OU=IT Department/CN=example.com"
else
    echo "Either the ${INSIGHTS_PROXY_NAME} server.key or server.crt certificate is missing in ${CERTS_PATH}."
    exit 1
fi
echo ""
echo "--------------------------------------------"
echo "Available Certificates:"
ls -l "${CERTS_PATH}"
echo "--------------------------------------------"
