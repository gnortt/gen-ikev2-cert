#!/usr/bin/env bash

set -e

if [ $# -le 3 ]; then
    echo "Usage: $0 [server directory] [output directory] [client cn] [days]"
    exit 1
fi

IN_DIR=$1
OUT_DIR=$2
CLIENT_CN=$3
DAYS=$4

CA_SUBJECT="$(openssl x509 -noout -subject -in "$IN_DIR"/ca.crt)"
CA_CN="${CA_SUBJECT:13}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

ipsec pki \
    --gen \
    --type ed25519 \
    --outform pem \
> "$OUT_DIR/$CLIENT_CN.key"

ipsec pki \
    --pub \
    --in "$OUT_DIR/$CLIENT_CN.key" \
| ipsec pki \
    --issue \
    --lifetime $DAYS \
    --cacert "$IN_DIR"/ca.crt \
    --cakey "$IN_DIR"/ca.key \
    --dn "CN=$CLIENT_CN" \
    --san "$CLIENT_CN" \
    --flag clientAuth \
    --outform pem \
> "$OUT_DIR/$CLIENT_CN.crt"

openssl pkcs12 \
    -export \
    -passout pass: \
    -inkey "$OUT_DIR/$CLIENT_CN.key" \
    -in "$OUT_DIR/$CLIENT_CN.crt" \
    -name "$CLIENT_CN" \
    -certfile "$IN_DIR"/ca.crt \
    -caname "$CA_CN" \
    -out "$OUT_DIR/$CLIENT_CN.p12"

chmod 600 "$OUT_DIR"/*.key "$OUT_DIR"/*.p12