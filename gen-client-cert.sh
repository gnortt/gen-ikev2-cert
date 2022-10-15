#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [server directory] [output directory] [client cn] [keysize] [days]"
    exit
}

if [ "$#" -lt 5 ]; then
    usage
fi

IN_DIR=$1
OUT_DIR=$2
CLIENT_CN=$3
KEY_SIZE=$4
DAYS=$5

CA_SUBJECT="$(openssl x509 -noout -subject -in $IN_DIR/ca.crt)"
CA_CN="${CA_SUBJECT:13}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

ipsec pki \
    --gen \
    --type rsa \
    --size $KEY_SIZE \
    --outform pem \
> "$OUT_DIR/$CLIENT_CN.key"

ipsec pki \
    --pub \
    --type rsa \
    --in "$OUT_DIR/$CLIENT_CN.key" \
| ipsec pki \
    --issue \
    --lifetime $DAYS \
    --digest sha256 \
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