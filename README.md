# insights-proxy
Insights Proxy to RedHat's Hybrid Cloud Console


## Architecture

This container leverages the [ubi9/nginx-124](https://catalog.redhat.com/software/containers/rhel9/nginx-124/657b0584200b5c4483d7e5f4?architecture=amd64&image=6658a67d302d7f34810970fe&container-tabs=overview) NGINX web server and reverse proxy to channel all communications to the RedHat Hybrid Cloud Console at [console.redhat.com](console.redhat.com).

## Development

This repo utilizes [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for differentiating the different types of commits.

Building the Insigihts Proxy container is provided via the Makefile. This can be done as follows:

```
$ make build
```

This builds the `localhost/insights-proxy:latest` container image.

## Insights Proxy Documentation

- [Insights Proxy Notes](doc/notes.md)

