#!/bin/bash
#
# Create the self signed certificates and PEM file for the proxy if not included.

set -e

# Let's make sure our certificates directory exists.
CERTS_PATH="${APP_ROOT}/certs"
mkdir -p "${CERTS_PATH}"

export CERT_PREFIX="insights-proxy"
export KEY_FILE="${CERTS_PATH}/${CERT_PREFIX}.key"
export CRT_FILE="${CERTS_PATH}/${CERT_PREFIX}.crt"
export PEM_FILE="${CERTS_PATH}/${CERT_PREFIX}.pem"

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
    echo "Either the ${INSIGHTS_PROXY_NAME} ${CERT_PREFIX}.key or ${CERT_PREFIX}.crt certificate is missing in ${CERTS_PATH}."
    exit 1
fi

if [ ! -f "${PEM_FILE}" ]; then
    echo "Creating ${INSIGHTS_PROXY_NAME} PEM file ..."
    cat "${KEY_FILE}" >  "${PEM_FILE}"
    cat "${CRT_FILE}" >> "${PEM_FILE}"
fi
echo ""
echo "--------------------------------------------"
echo "Available Certificates:"
ls -l "${CERTS_PATH}"
echo "--------------------------------------------"
