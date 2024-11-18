# rhproxy-engine
Insights proxy NGINX container to RedHat's Insights services.


## Architecture

This container builds version 1.24 of NGINX web server and includes the http proxy connect module which provides tunneling support. The NGINX web server services content at the default port 8443 and provides the forward proxy tunnel at the default port of 3128 for all communications to the RedHat Hybrid Cloud Console at [console.redhat.com](console.redhat.com) and related subscription and authorization sites.

## Development

Building the Insights proxy container is provided via the Makefile. This can be done as follows:

```
$ make build
```

This builds the `localhost/rhproxy-engine:latest` container image.

## Insights proxy Documentation

- [Insights proxy Notes](doc/NOTES.md)

## Build Repository

Release builds of the Insights proxy container are located in the following repository:

- [quay.io/insights_proxy/rhproxy-engine](https://quay.io/insights_proxy/rhproxy-engine?tab=tags)


