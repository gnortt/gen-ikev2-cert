#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [output directory] [ca cn] [server cn] [keysize] [days]"
    exit
}

if [ "$#" -lt 5 ]; then
    usage
fi

OUT_DIR=$1
CA_CN=$2
SERVER_CN=$3
KEY_SIZE=$4
DAYS=$5

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

ipsec pki \
    --gen \
    --type rsa \
    --size $KEY_SIZE \
    --outform pem \
> "$OUT_DIR"/ca.key

ipsec pki \
    --gen \
    --type rsa \
    --size $KEY_SIZE \
    --outform pem \
> "$OUT_DIR/$SERVER_CN.key"

ipsec pki \
    --self \
    --type rsa \
    --ca \
    --lifetime $DAYS \
    --digest sha256 \
    --in "$OUT_DIR"/ca.key \
    --dn "CN=$CA_CN" \
    --outform pem \
> "$OUT_DIR"/ca.crt

ipsec pki \
    --pub \
    --type rsa \
    --in "$OUT_DIR/$SERVER_CN.key" \
| ipsec pki \
    --issue \
    --lifetime $DAYS \
    --digest sha256 \
    --cacert "$OUT_DIR"/ca.crt \
    --cakey "$OUT_DIR"/ca.key \
    --dn "CN=$SERVER_CN" \
    --san "$SERVER_CN" \
    --flag serverAuth \
    --outform pem \
> "$OUT_DIR/$SERVER_CN.crt"

chmod 600 "$OUT_DIR"/*.key
