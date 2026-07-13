#!/bin/sh
exec drill -p "${PORT:-53}" one.one.one.one @127.0.0.1
