# gen-ikev2-cert

Self-signed IPsec TLS certificate generator script. Quickly generate a certificate authority, server TLS key and certificate, and one or more client TLS keys and certificates.

Generated are `rsa` (or `ed25519`) CA, server and client keys, and `pkcs12` formatted key and certificate bundles.

# Requirements

Required dependencies:

- strongswan
- strongswan-pki
- openssl

# Usage

`gen-server-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-server-cert.sh [options] <ca_cn> <server_cn>

        Options:
          -k    rsa key size, default 2048 bits
          -l    certificate lifetimes, default 365 days
          -o    output directory, default <server_cn>
          -t    key type (rsa or ed25519), default ed25519

    > ./gen-server-cert.sh rootCA example.com
    > ls example.com

    ca.crt  ca.key  example.com.crt  example.com.key
```

Create client TLS keys and certificates using `gen-client-cert.sh`.

You will be asked to enter a password used to encrypt the `pkcs12` file.

```
    Usage: ./gen-client-cert.sh [options] <server_directory> <client_cn>

        Options:
          -k    rsa key size, default 2048 bits
          -l    certificate lifetimes, default 365 days
          -o    output directory, default <client_cn>
          -t    key type (rsa or ed25519), default ed25519

    > ./gen-client-cert.sh example.com client01
    > Enter Export Password: ******
    > Verifying - Enter Export Password: ******
    > ls client01

    ca.crt  client01.crt  client01.key  client01.p12
```