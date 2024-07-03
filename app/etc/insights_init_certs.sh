#!/bin/bash
#
# Create the self signed certificates and PEM file for the proxy if not included.

set -e

# Let's make sure our certificates directory exists.
mkdir -p "${APP_CERTS}"

export CERT_PREFIX="insights-proxy"
export KEY_FILE="${APP_CERTS}/${CERT_PREFIX}.key"
export CRT_FILE="${APP_CERTS}/${CERT_PREFIX}.crt"
export PEM_FILE="${APP_CERTS}/${CERT_PREFIX}.pem"

if [ -f "${KEY_FILE}" ] && [ -f "${CRT_FILE}" ]; then
    echo "Using ${INSIGHTS_PROXY_NAME} certificates ..."
    openssl rsa -in "${KEY_FILE}" -check
    openssl x509 -in "${CRT_FILE}" -text -noout
elif [ ! -f "${KEY_FILE}" ] && [ ! -f "${CRT_FILE}" ]; then
    echo "Creating ${INSIGHTS_PROXY_NAME} certificates ..."
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout "${KEY_FILE}" \
        -out "${CRT_FILE}" \
        -subj "/C=US/ST=Raleigh/L=Raleigh/O=IT/OU=IT Department/CN=insights-proxy" \
        -addext "subjectAltName=DNS:localhost"
    chmod 600 "${KEY_FILE}"
else
    echo "Either the ${INSIGHTS_PROXY_NAME} ${CERT_PREFIX}.key or ${CERT_PREFIX}.crt certificate is missing in ${APP_CERTS}."
    exit 1
fi

if [ ! -f "${PEM_FILE}" ]; then
    echo "Creating ${INSIGHTS_PROXY_NAME} PEM file ..."
    cat "${KEY_FILE}" >  "${PEM_FILE}"
    cat "${CRT_FILE}" >> "${PEM_FILE}"
fi


if [ "${INSIGHTS_PROXY_DEBUG_CONFIG}" = "1" ]; then
    echo
    echo "----------------------------------------------------------------------"
    echo "Available Certificates:"
    echo
    ls -l "${APP_CERTS}"
    echo
fi
