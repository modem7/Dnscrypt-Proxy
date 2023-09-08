# syntax = docker/dockerfile:latest

FROM alpine:edge as base
ARG TARGETARCH

LABEL maintainer="modem7"
LABEL description="A flexible DNS proxy, with support for modern encrypted DNS protocols \
                   such as DNSCrypt v2 and DNS-over-HTTP/2." \
                   url="https://github.com/jedisct1/dnscrypt-proxy"

FROM base AS base-amd64
ENV S6_OVERLAY_ARCH=x86_64

FROM base AS base-arm64
ENV S6_OVERLAY_ARCH=aarch64

FROM base-${TARGETARCH}${TARGETVARIANT}

ARG S6_OVERLAY_VERSION=3.1.5.0

# Add S6 Overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp/s6-overlay.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp

# Add S6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    PORT=53 \
    S6_VERBOSITY="1" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0" \
    TZ="Europe/London"

RUN <<EOF
    set -x
    apk upgrade --update --no-cache
    tar -C / -Jxpf /tmp/s6-overlay.tar.xz
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

    apk add --no-cache \
        bash \
        ca-certificates \
        tzdata
        
    apk add --no-cache -uU \
        dnscrypt-proxy=2.1.5-r1 \
        drill=1.8.3-r2
    rm -rf /tmp/* \
           /var/cache/apk/*
EOF

COPY root/ /
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

USER dnscrypt

EXPOSE $PORT/tcp
EXPOSE $PORT/udp

HEALTHCHECK --interval=20s --timeout=20s --retries=3 --start-period=10s \
    CMD drill -p $PORT one.one.one.one @127.0.0.1 || exit 1

ENTRYPOINT [ "/init" ]
