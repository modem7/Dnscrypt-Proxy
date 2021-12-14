# DNSCrypt-Proxy

[![Docker Pulls](https://img.shields.io/docker/pulls/modem7/dnscrypt-proxy)](https://hub.docker.com/r/modem7/dnscrypt-proxy) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/dnscrypt-proxy/latest) 
[![Build Status](https://drone.modem7.com/api/badges/modem7/Dnscrypt-Proxy/status.svg)](https://drone.modem7.com/modem7/Dnscrypt-Proxy) 
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/Dnscrypt-Proxy)](https://github.com/modem7/Dnscrypt-Proxy)

A DNS server container which utilises several anonymised, non-logging, non-filtering DNS over HTTPS servers by utilizing DNSCrypt Proxy (https://github.com/jedisct1/dnscrypt-proxy, https://dnscrypt.info/).

In this config, tcp and udp port 53 must be free on the host:

```bash
docker run -dt --dns 127.0.0.1 -p 53:53/udp -p 53:53/tcp --name dnscrypt-proxy --restart unless-stopped modem7/dnscrypt-proxy
```

If you need it to listen on an alternate port:

```bash
docker run -dt --dns 127.0.0.1 -p 5353:53/udp -p 5353:53/tcp --name dnscrypt-proxy --restart unless-stopped modem7/dnscrypt-proxy
```

## Docker-compose
```bash
version: "2.4"

services:

  #DNSCrypt-Proxy - Non-caching, Non-logging, DNSSEC DNS Resolver
  dnscrypt-proxy:
    image: modem7/dnscrypt-proxy:latest
    container_name: Dnscrypt-proxy
    hostname: DNSCrypt
    dns:
      - 127.0.0.1
    ports:
      - "53:53"
    volumes:
      #- $USERDIR/DNSCrypt/dnscrypt-proxy.toml:/etc/dnscrypt-proxy/dnscrypt-proxy.toml # Uncomment if you want to define your own dnscrypt-proxy.toml file
      - /etc/localtime:/etc/localtime:ro
    restart: always
    mem_limit: 100m
    mem_reservation: 30m
```
---------------

## Modifications
If you want to modify the server list being used or other parameters you can clone the repo, modify the configuration files, build your own image, and run from that build.

Alternatively: Uncomment the value in volumes to substitute your own local configuration.

Clone Repo:
git clone https://github.com/modem7/Dnscrypt-Proxy.git

Modify DNSCrypt-Proxy config:
dnscrypt/dnscrypt-proxy.toml

Modify servers to meet your needs, adjust other params if desired.  For more detail around those settings, see: https://github.com/jedisct1/dnscrypt-proxy/wiki/Configuration-Sources

Run the build:
```bash
docker build -f dnscrypt-proxy/Dockerfile dnscrypt-proxy/ -t dnscrypt-proxy-build
```

Run a container from the build:
```bash
docker run -dt --dns 127.0.0.1 -p 53:53/udp -p 53:53/tcp --name dnscrypt-proxy --restart unless-stopped dnscrypt-proxy-build
```

## Troubleshooting
If you run into issues after updating, remove the container and volume and recreate to get the latest config
