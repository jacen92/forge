Notes on local certificates
---------------------------

Running the playbook in docker will automatically create self signed certificates if they are not provided here.
Put your certificate and key files here and register them in vars.yml in DOMAIN_CERT_NAME and DOMAIN_CERT_KEY_NAME.

The self signed certificates are created with [mkcert](https://github.com/FiloSottile/mkcert)
The CA will be found in $SHARED_DIRECTORY and could be installed and reused for other $TARGETs

```
#exemple
mkcert forge.local "forge.domain.lan" 192.168.1.1
```
