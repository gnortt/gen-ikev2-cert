# gen-ikev2-cert

Self-signed IPsec TLS certificate generator script. Quickly generate a certificate authority, server TLS key and certificate, and one or more client TLS keys and certificates.

Generated are `ed25519` ECC CA, server and client keys, and `pkcs12` formatted client certificate.

# Requirements

Required dependencies:

- IPsec server, such as strongswan
- openssl

# Usage

`gen-server-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-server-cert.sh [output directory] [ca cn] [server cn] [days]

    > ./gen-server-cert.sh example rootCA example.com 365
    > ls example

    ca.crt  ca.key  example.com.crt  example.com.key
```

After creating a certificate authority and server TLS key and certificate, create client TLS keys and certificates using `gen-client-cert.sh`: 

```
    Usage: ./gen-client-cert.sh [server directory] [output directory] [client cn] [days]

    > ./gen-client-cert.sh example client01 client01 365
    > ls client01

    client01.crt  client01.key  client01.p12
```