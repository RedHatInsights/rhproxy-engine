

## Insights proxy

The Insights proxy channels all Insights communication from the customer's site and systems
to the Red Hat Insights servers. The Insights proxy leverages NGINX to act as a forward proxy
to console.redhat.com, sso.redhat.com as well as related subscription endpoints.

The Insights proxy does not terminate SSL requests but rather does SSL tunneling and passthrough to the
back-end servers. With no SSL terminate, the Insights proxy does not have access to request
details and relies on tunneling to forward all SSL/TLS protocol.


### Accessing via curl:

- Direct to Insights:

```
$ curl -vvv -kL \
  --user {{user-id}}@redhat.com:{{user-password}} \
  https://console.redhat.com/api/inventory/v1/hosts
```

- Through the proxy using the -x option:

```
$ curl -vvv -kL \
  --user {{user-id}}@redhat.com:{{user-password}} \
  -x {{ip-of-proxy}}:3128 \
  https://console.redhat.com/api/inventory/v1/hosts
```

- Via the `https_proxy` environment variable:

```
$ export https_proxy="http://{{ip-of-proxy}}:3128"
$ curl -vvv -kL \
  --user {{user-id}}@redhat.com:{{user-password}} \
  https://console.redhat.com/api/inventory/v1/hosts
```

## Insights proxy web server

The Insights proxy also provides a web server at the default port of 8443 for serving files to clients.

You can access the landing page by opening

```
https://{{ip-of-proxy}}:8443
```

Which provides a link to the download folder.

Content from the download folder can also be fetched directly via curl. For example if `rhsm.conf` is provided, you can use the following to access it:

```
$ curl -kL https://{{ip-of-proxy}:8443/download/rhsm.conf -o rhsm.conf
```

