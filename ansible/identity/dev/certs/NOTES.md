Notes on local certificates
---------------------------

Put your certificate and key files here and register them in vars.yml in DOMAIN_CERT_NAME and DOMAIN_CERT_KEY_NAME.
If not certificate is provided then traefik will generated it own.

During development you can use the tools [mkcert](https://github.com/FiloSottile/mkcert)

```
#exemple
mkcert forge.local "forge.domain.lan" 192.168.1.1
```
