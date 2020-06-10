FROM alpine:edge

LABEL maintainer="Alex Lane <modem7@gmail.com>"
LABEL description="A flexible DNS proxy, with support for modern encrypted DNS protocols \
                   such as DNSCrypt v2 and DNS-over-HTTP/2." \
                   url="https://github.com/jedisct1/dnscrypt-proxy" \
                   version="2.0.43-r0"
ENV LOCAL_PORT 53
RUN apk update && \
    apk add --no-cache \ 
    dnscrypt-proxy=2.0.43-r0 \
    drill && \
    rm -rf /var/cache/apk/*

EXPOSE $LOCAL_PORT/udp

# Environment
ENV TZ Europe/London

ADD dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

USER dnscrypt

HEALTHCHECK --interval=5s --timeout=3s --start-period=10s \
    CMD drill -p $LOCAL_PORT one.one.one.one @127.0.0.1 || exit 1

CMD /usr/bin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml