Ansible base role for the Infrastructure base.

Content
=======

* backup: install stuff to do backup of the datacore on a remote FTP server.
* HTTPS: reverse-proxy with HTTPS.
* portainer: docker machine web interface.
* netdata: server monitoring web interface.

NOTES:
======

How to unban ip :
-----------------

```
$ export JAIL=ssh_gogs
$ export IP=192.168.0.20
$ sudo fail2ban-client set $JAIL unbanip $IP
```

Where $IP is the ban ip you want to unban and JAIL is in [gogs_ssh, gogs_ssh_scan]

When I am testing:

```
$ sudo fail2ban-client unban --all
```

How to make local certificate with mkcert:
------------------------------------------

During development you can use a local certificate to test https.
Let's Encrypt will behave as usual from internet if enabled with TRAEFIK_USE_LETSENCRYPT.
Get mkcert from [github](https://github.com/FiloSottile/mkcert).

```
# make it executable and move it to the /usr/local/bin directory.
sudo chmod +x mkcert-v1.4.1-linux-amd64
sudo mv mkcert-v1.4.1-linux-amd64 /usr/local/bin/
sudo ln -s /usr/local/bin/mkcert-v1.4.1-linux-amd64 /usr/local/bin/mkcert

# create the local certificate authority key.
mkcert
# Install the CA on you web browser.
mkcert -install

# Make the forge certificate for traefik.
mkcert forge.local "*.forge.local" 192.168.0.20

# move created pem files in the files/ssl directory.
mv *.pem files/ssl/
```

Sources for https:
------------------

https://jimfrenette.com/2018/03/ssl-certificate-authority-for-docker-and-traefik/
https://community.letsencrypt.org/t/error-when-i-try-to-generate-certificate-with-traefikv2-acme-tls-challenge-docker-swarm/118750/6
https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/
https://zestedesavoir.com/billets/3355/traefik-v2-https-ssl-en-localhost/
