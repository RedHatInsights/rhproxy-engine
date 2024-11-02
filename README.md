# rhproxy-engine
Insights proxy NGINX Engine to RedHat's Hybrid Cloud Console


## Architecture

This container builds version 1.24 of NGINX web server and includes the http proxy connect module which provides tunneling support. The NGINX web server services content at the default port 8443 and provides the forward proxy tunnel at the default port of 3128 for all communications to the RedHat Hybrid Cloud Console at [console.redhat.com](console.redhat.com) and related subscription and authorization sites.

## Development

This repo utilizes [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for differentiating the different types of commits.

Building the Insights proxy container is provided via the Makefile. This can be done as follows:

```
$ make build
```

This builds the `localhost/rhproxy-engine:latest` container image.

## Insights proxy Documentation

- [Insights proxy Notes](doc/notes.md)

