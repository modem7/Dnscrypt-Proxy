FROM alpine as builder

ARG OS=linux
ARG ARCH=x86_64
ARG VERSION=2.0.42
ARG SHA256SUM=a9869b8694e6ea1d22e8a5c1339ddc9541399db5203e63d92e823a004a9b2ccd

RUN apk add curl ca-certificates

RUN curl -fLsS -o dnscrypt-proxy.tar.gz https://github.com/jedisct1/dnscrypt-proxy/releases/download/${VERSION}/dnscrypt-proxy-${OS}_${ARCH}-${VERSION}.tar.gz && \
    sum=$(sha256sum -b dnscrypt-proxy.tar.gz | awk '{ print $1 }') && \
    if [ "${sum}" != "${SHA256SUM}" ]; then \
        echo "expected sum ${SHA256SUM} does not match downloaded file sum ${sum}"; \
        exit 1; \
    fi && \
    tar -xzvf dnscrypt-proxy.tar.gz && \
    mv ${OS}-${ARCH} dnscrypt-proxy
	
ADD dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
ADD test.sh /etc/dnscrypt-proxy/test.sh

FROM alpine
LABEL maintainer="Alex Lane <modem7@gmail.com>" \
      description="A flexible DNS proxy, with support for modern encrypted DNS protocols \
                  such as DNSCrypt v2 and DNS-over-HTTP/2." \
      url="https://github.com/jedisct1/dnscrypt-proxy"

Uncomment these if you want to enable the healthcheck
RUN apk add --no-cache bash \
    && apk add --no-cache curl \
    && apk add --update --no-cache bind-tools \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
	
# Environment
ENV TZ Europe/London

# publish port DNS over UDP & TCP
EXPOSE 53/TCP 53/UDP 5353/TCP 5353/UDP

# service running
STOPSIGNAL SIGTERM

# Multi stage build
WORKDIR /etc/dnscrypt-proxy/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /dnscrypt-proxy/dnscrypt-proxy /usr/local/bin/
COPY --from=builder /etc/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/
COPY --from=builder /etc/dnscrypt-proxy/test.sh /etc/dnscrypt-proxy/

RUN addgroup -g 1000 proxy && \
    adduser -u 1000 -G proxy -H proxy -S && \
    chown -R proxy:proxy /etc/dnscrypt-proxy

# command
ENTRYPOINT [ "dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml", "-pidfile", "/etc/dnscrypt-proxy/dnscryptProxy.pid"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD dig one.one.one.one || exit 1