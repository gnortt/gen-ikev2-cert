#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <ca_cn> <server_cn>

    Options:
      -k    rsa key size, default 2048 bits
      -l    certificate lifetimes, default 365 days
      -o    output directory, default <server_cn>
      -t    key type (rsa or ed25519), default ed25519"
    exit 1
}

while getopts "k:l:o:t:" flag; do
    case "$flag" in
        k)  KEY_SIZE=$OPTARG;;
        l)  DAYS=$OPTARG;;
        o)  OUT_DIR=$OPTARG;;
        t)  TYPE=$OPTARG;;
        \?) usage;;
    esac
done

shift $((OPTIND - 1))

if [ $# -le 1 ]; then
    usage
fi

CA_CN=$1
SERVER_CN=$2

: "${KEY_SIZE:=2048}"
: "${DAYS:=365}"
: "${OUT_DIR:=$SERVER_CN}"
: "${TYPE:=ed25519}"

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
