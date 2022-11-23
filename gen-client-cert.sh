#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <server_directory> <client_cn>

    Options:
      -k    rsa key size, default 2048 bits
      -l    certificate lifetimes, default 365 days
      -o    output directory, default <client_cn>
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

IN_DIR=$1
CLIENT_CN=$2

: "${KEY_SIZE:=2048}"
: "${DAYS:=365}"
: "${OUT_DIR:=$CLIENT_CN}"
: "${TYPE:=ed25519}"

CA_SUBJECT="$(openssl x509 -noout -subject -in "$IN_DIR"/ca.crt)"
CA_CN="${CA_SUBJECT:13}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

case "$TYPE" in
    rsa)
        ipsec pki \
            --gen \
            --type rsa \
            --size $KEY_SIZE \
            --outform pem \
        > "$OUT_DIR/$CLIENT_CN.key"
        ;;
    ed25519) 
        ipsec pki \
            --gen \
            --type ed25519 \
            --outform pem \
        > "$OUT_DIR/$CLIENT_CN.key"
        ;; 
    *)
        echo "Invalid key type: choose one of rsa or ed25519";
        exit 1;;
esac

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