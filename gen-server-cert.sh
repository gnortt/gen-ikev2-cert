#!/usr/bin/env bash

set -e

if [ $# -le 3 ]; then
    echo "Usage: $0 [output directory] [ca cn] [server cn] [days]"
    exit 1
fi

OUT_DIR=$1
CA_CN=$2
SERVER_CN=$3
DAYS=$4

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

ipsec pki \
    --gen \
    --type ed25519 \
    --outform pem \
> "$OUT_DIR"/ca.key

ipsec pki \
    --gen \
    --type ed25519 \
    --outform pem \
> "$OUT_DIR/$SERVER_CN.key"

ipsec pki \
    --self \
    --ca \
    --lifetime $DAYS \
    --in "$OUT_DIR"/ca.key \
    --dn "CN=$CA_CN" \
    --outform pem \
> "$OUT_DIR"/ca.crt

ipsec pki \
    --pub \
    --in "$OUT_DIR/$SERVER_CN.key" \
| ipsec pki \
    --issue \
    --lifetime $DAYS \
    --cacert "$OUT_DIR"/ca.crt \
    --cakey "$OUT_DIR"/ca.key \
    --dn "CN=$SERVER_CN" \
    --san "$SERVER_CN" \
    --flag serverAuth \
    --outform pem \
> "$OUT_DIR/$SERVER_CN.crt"

chmod 600 "$OUT_DIR"/*.key
