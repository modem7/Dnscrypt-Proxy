FROM alpine:edge

ENV LOCAL_PORT=53
ENV DNSCRYPT_VERSION=2.1.0-r0

LABEL maintainer="Alex Lane <modem7@gmail.com>"
LABEL description="A flexible DNS proxy, with support for modern encrypted DNS protocols \
                   such as DNSCrypt v2 and DNS-over-HTTP/2." \
                   url="https://github.com/jedisct1/dnscrypt-proxy" \
                   version="{$DNSCRYPT_VERSION}"

RUN apk update && \
    apk add --no-cache \ 
    dnscrypt-proxy=$DNSCRYPT_VERSION \
    drill && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

EXPOSE $LOCAL_PORT/udp

COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml

USER dnscrypt

HEALTHCHECK --interval=20s --timeout=20s --retries=3 --start-period=10s \
    CMD drill -p $LOCAL_PORT one.one.one.one @127.0.0.1 || exit 1

CMD /usr/bin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml