

## Insights Proxy

The Insights Proxy channels all Insights communication from the customer's site and systems 
to the Red Hat Insights servers. The Insights Proxy leverages NGINX to act as a forward proxy
to console.redhat.com, sso.redhat.com as well as optionally the staging servers or later on
the local On-Prem Insights installation.

The Insights Proxy does not terminate SSL requests but rather does SSL passthrough to the
back-end servers. With no SSL terminate, the Insights Proxy does not have access to request
details and thus relies on the SNI (Server Name Indication) in the TLS handshake protocol
which includes the target server_name.

With the server_name, the Insights Proxy propery channels the requests to the appropriate
upstream servers.

TLS SNI uses a Hello insecure message which includes the hostname before transferring to the
secure 443 for the request. It is part of TLS 1.2.

OpenSSL populates the SNI buffers upon normal requests. It had some issues in the past
doing so going through a proxy:


Required fixes:

Ensure s_client sends SNI data when used with -proxy

  - [https://github.com/openssl/openssl/issues/17232](https://github.com/openssl/openssl/issues/17232)
  - [https://github.com/openssl/openssl/pull/17248](https://github.com/openssl/openssl/pull/17248)


### Accessing via curl:

- Direct to Insights:

```
$ curl -vvv -kL \
  --user {{user-id}}@redhat.com:{{user-password}} \
  https://console.redhat.com/api/inventory/v1/hosts
```

- Through the Proxy using --resolve:

```
$ curl -vvv -kL \
  --user {{user-id}}@redhat.com:{{user-password}} \
  --resolve console.redhat.com:443:{{ip-of-proxy}} \
  https://console.redhat.com/api/inventory/v1/hosts
```
