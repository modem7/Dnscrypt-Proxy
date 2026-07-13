# DNSCrypt-Proxy

[![Docker Pulls](https://img.shields.io/docker/pulls/modem7/dnscrypt-proxy)](https://hub.docker.com/r/modem7/dnscrypt-proxy)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/dnscrypt-proxy/latest)](https://hub.docker.com/r/modem7/dnscrypt-proxy)
[![status-badge](https://woodpecker.modem7.com/api/badges/5/status.svg)](https://woodpecker.modem7.com/repos/5)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/Dnscrypt-Proxy)](https://github.com/modem7/Dnscrypt-Proxy)
[![License: MIT](https://img.shields.io/github/license/modem7/Dnscrypt-Proxy)](LICENCE.txt)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

DNS resolver container built on [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy), running on [S6 Overlay](https://github.com/just-containers/s6-overlay). Supports `linux/amd64` and `linux/arm64`.

By default it routes every query through [Anonymized DNS](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Anonymized-DNS) relays to DNSCrypt-only servers that don't log and don't filter - no single server ever sees both who you are and what you're resolving.

---

## Tags

| Tag | Description |
| :---: | --- |
| `latest` | Latest dnscrypt-proxy build |

---

## Quick start

```yaml
services:
  dnscrypt-proxy:
    image: modem7/dnscrypt-proxy:latest
    container_name: dnscrypt-proxy
    hostname: dnscrypt-proxy
    dns:
      - 127.0.0.1
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - /etc/localtime:/etc/localtime:ro
      # - ./dnscrypt-proxy.toml:/etc/dnscrypt-proxy/dnscrypt-proxy.toml:ro  # uncomment to supply your own config
    restart: unless-stopped
    mem_limit: 100m
    mem_reservation: 30m
```

```console
docker compose up -d
```

TCP and UDP port 53 must be free on the host. Plain `docker run` works just as well:

```console
docker run -d \
  --name dnscrypt-proxy \
  --dns 127.0.0.1 \
  -p 53:53/tcp -p 53:53/udp \
  --restart unless-stopped \
  modem7/dnscrypt-proxy
```

---

## Environment variables

| Variable | Description | Default |
| :---: | --- | --- |
| `TZ` | Container timezone | `Europe/London` |
| `LOG_LEVEL` | Log verbosity, 0-6 (0 is very verbose, 6 only fatal errors) | `2` |
| `PORT` | Port dnscrypt-proxy listens on inside the container, both TCP and UDP | `53` |
| `MAX_CLIENTS` | Maximum simultaneous client connections | `1000` |
| `CACHE_SIZE` | DNS cache size, in entries | `8192` |
| `MONITORING_UI_ENABLED` | Enable the built-in monitoring web UI (`true`/`false`) - see below | `false` |
| `MONITORING_UI_LISTEN_ADDRESS` | Listen address for the monitoring UI | `127.0.0.1:8080` |
| `MONITORING_UI_USERNAME` | Monitoring UI basic auth username | `admin` |
| `MONITORING_UI_PASSWORD` | Monitoring UI basic auth password - **change this if you enable the UI** | `changeme` |
| `MONITORING_UI_PROMETHEUS_ENABLED` | Expose a `/metrics` endpoint on the monitoring UI (`true`/`false`) | `false` |
| `IP_ENCRYPTION_ALGORITHM` | Encrypt client IPs in plugin logs - `none`, `ipcrypt-deterministic`, `ipcrypt-nd`, `ipcrypt-ndx` or `ipcrypt-pfx` | `none` |
| `IP_ENCRYPTION_KEY` | Hex-encoded key for `IP_ENCRYPTION_ALGORITHM` (required if not `none`) | — |

`PORT` changes what dnscrypt-proxy listens on *inside* the container - map it to whatever host port you want, e.g. `-e PORT=5353 -p 5353:5353/tcp -p 5353:5353/udp`.

`MONITORING_UI_ENABLED` and `MONITORING_UI_PROMETHEUS_ENABLED` must be the literal strings `true` or `false` - anything else produces an invalid config.

---

## Monitoring UI

dnscrypt-proxy has a built-in web UI showing recent queries, load-balancer stats, and an optional Prometheus `/metrics` endpoint. It's off by default. To enable it:

```yaml
services:
  dnscrypt-proxy:
    environment:
      - MONITORING_UI_ENABLED=true
      - MONITORING_UI_PASSWORD=something-not-changeme
    ports:
      - "127.0.0.1:8080:8080"  # only if you need to reach it from outside the container
```

The UI binds to loopback by default, so it isn't reachable unless you also publish its port. If you do publish it, set `MONITORING_UI_PASSWORD` to something other than the default first.

---

## Configuration

The shipped [`dnscrypt-proxy.toml`](dnscrypt-proxy.toml) is deliberately opinionated: DNSCrypt-only (no DoH/ODoH), DNSSEC required, and every query routed through [Anonymized DNS](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Anonymized-DNS) relays. If that doesn't suit you, mount your own:

```console
git clone https://github.com/modem7/Dnscrypt-Proxy.git
cd Dnscrypt-Proxy
```

Edit `dnscrypt-proxy.toml` to taste - server selection, relays, blocklists, and everything else is documented inline. See the [dnscrypt-proxy wiki](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Configuration-Sources) for the full option reference. Then either mount it over the built-in one (see the commented-out volume line in [Quick start](#quick-start) above), or build your own image:

```console
docker build -t dnscrypt-proxy-build .
docker run -d --name dnscrypt-proxy --dns 127.0.0.1 -p 53:53/tcp -p 53:53/udp --restart unless-stopped dnscrypt-proxy-build
```

---

## Troubleshooting

If queries stop resolving after an update, remove the container (and volume, if you're mounting one) and recreate it to pick up the latest shipped config.

To check what the proxy is actually doing:

```console
docker logs -f dnscrypt-proxy
```

---

## License

[MIT](LICENCE.txt)
