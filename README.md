Ansible roles to setup infrastructure on computer running Debian or Ubuntu via docker.

Concept
=======

This projects aims to create a full software forge with all required services for development, home automation, storage, etc.
All services are available throught traefik which act as a TLS proxy. If no certificate is provided for the local network then traefik
will create it's own certificates for all services (you will need to accept each of them on your browser).
Only traefik's frontend is not exposed with TLS and will be acccessible with HTTP (a switch will be added in a next version to disable this frontend).

A docker image contains all requirements to deploy a forge in a TARGET with the private key to access the root user throught SSh.
An identity archive should be provided to customize the installation else a dev identity will be set up.

The full installation take 60minutes on my Rpi4 and 10Go of storage, Less if you skip some services.

How to make an identity
-----------------------

An identity is a compressed folder containing some files and secrets.
Password protected archive are supported, add a file with the password in `shared/identity_password`.
The folder structure exemple can be found in `ansible/identity/dev` so you can copy this directory and customize your own then archive it.

```
# Name your new identity (without spaces).
export IDENTITY=myIdentity
git clone <this repo>
cd forge

# create a directory where to store your identities (not mandatory to be in the repository)
mkdir shared

# Copy the dev identity
cp -R ansible/identity/dev shared/$IDENTITY
cd shared

# To add certificate read the NOTES.md in identity/dev.
# edit $IDENTITY/vars
nano $IDENTITY/vars

# edit the secrets then change the password for your new identity with ansible-vault rekey (the default password is "password")
EDITOR=nano ansible-vault edit $IDENTITY/vault.yml
ansible-vault rekey $IDENTITY/vault.yml

# create the archive
zip -r $IDENTITY.zip $IDENTITY
```

You can provide a custom CA for your local network and prevent traefik to create a lot of untrusted certificates by following [this](/identity/dev/certs/NOTES.md).

All available services will be installed and configured to be ready to use but, except the infra core (traefik, portainer, ...), all services will be stopped by default and you will need to use portainer to start them.
This behavior depends on the parameter SERVICE_DEFAULT_STATE for each services in the vars/main.yml files of each roles.

How to use configure a forge
----------------------------

```
# Copy the private key to access the remote host in the shared directory:
cp ~/.ssh/id_rsa shared/ansible_key

# Build the image (or use the official one):
docker build --rm -t forge -f Dockerfile .

# Run the image (it will configure the TARGET)
docker run -ti --rm -v $(pwd)/shared:/opt/shared -e TARGET=192.168.0.404 -e IDENTITY=$IDENTITY -e VAULT_PASSWORD=<new_password> forge
```

The vault password can be provided in the shared directory in a file $IDENTITY_vault_password.
You can also customize authorized_keys for users and fdroid service.
For more information about custom parameters read the entrypoint.sh file.

Services
========

infra:
------

* nginx: HTTP server for static page in this case [https://hub.docker.com/_/nginx].
* traefik: HTTPS support and reverse proxy with domain name [https://hub.docker.com/r/arm32v6/traefik/].
* portainer: Docker images manager [https://hub.docker.com/r/portainer/portainer/].
* Netdata: The open-source, real-time, performance and health monitoring. [https://hub.docker.com/r/netdata/netdata].

![Renderer screenshot](/documents/screenshots/infrastructure.png)

Continuous integration:
-----------------------

* gogs: github like server, source storage (lighter than gitlab) [https://hub.docker.com/r/gogs/gogs-rpi/].
* jenkins: The leading open source automation server [https://github.com/jenkinsci/docker].
* redmine: A flexible project management web application [https://hub.docker.com/_/redmine].

![Renderer screenshot](/documents/screenshots/development.png)

Hardware interaction:
---------------------

* insolante: gerber to gcode converter (wrapper to pcb2gcode) [https://hub.docker.com/r/ngargaud/insolante].
* mqtt: Mosquitto broker for the Internet of Things [https://hub.docker.com/_/eclipse-mosquitto].
* nodered: Flow-based programming for the Internet of Things [https://hub.docker.com/r/nodered/node-red].
* octoprint: The snappy web interface for your 3D printer. [https://hub.docker.com/r/nunofgs/octoprint].

![Renderer screenshot](/documents/screenshots/hardware.png)

Social and media:
-----------------

* Wordpress: The WordPress rich content management system [https://hub.docker.com/_/wordpress/].
* Peertube: Federated video streaming platform [https://hub.docker.com/r/ngargaud/peertube].

![Renderer screenshot](/documents/screenshots/social.png)

Storage:
--------

* nexus: Artifact manager and docker registry [https://github.com/sonatype/docker-nexus3].
* fdroid: Android application server [https://hub.docker.com/r/ngargaud/fdroid-server].
* nextcloud: Google drive alternative [https://hub.docker.com/_/nextcloud/].

Productivity:
-------------

* Grocy: RP beyond your fridge - grocy is a web-based self-hosted groceries & household management solution for your home. [https://hub.docker.com/r/linuxserver/grocy].
* Odoo: (formerly known as OpenERP) is a suite of open-source business apps [https://hub.docker.com/_/odoo].
* It-tools: Useful tools for developer and people working in IT. [https://hub.docker.com/r/corentinth/it-tools].
* Onlyoffice: (Feature-rich web-based office suite with a vast range of collaborative capabilities. [https://hub.docker.com/r/onlyoffice/documentserver].


Machine Learning:
-----------------

* Label Studio: Label Studio is a multi-type data labeling and annotation tool with standardized output format.[https://hub.docker.com/r/heartexlabs/label-studio].
* Audio Webui: A webui for different audio related Neural Networks.[https://github.com/jacen92/audio-webui-docker].
* Text Webui: A Gradio web UI for Large Language Models. Supports transformers, GPTQ, llama.cpp (ggml), Llama models.[https://github.com/oobabooga/text-generation-webui.git].
* Stable disffusion Webui: Easy Docker setup for Stable Diffusion with user-friendly UI (default to AUTOMATIC1111).[https://github.com/AbdBarho/stable-diffusion-webui-docker].


![Renderer screenshot](/documents/screenshots/storage.png)

Port listing (exposed from all docker containers)
=================================================

| Service           | port | protocol | Role    | publicly exposed | subDomain |
| ----------------- |:----:|:--------:|:-------:|:----------------:|:---------:|
| Traefik           | 80   |   http   | infra   |        yes       |           |
| Traefik           | 443  |   https  | infra   |        yes       |           |
| Traefik           | 8000 |   http   | infra   |        no        |           |
| Nginx             | 8001 |   http   | infra   |        no        |   home.   |
| Portainer         | 8010 |   http   | infra   |        no        |           |
| Netdata           | 8011 |   http   | infra   |        no        | monitor.  |
| Gogs              | 8021 |   http   | CI      |        no        |   git.    |
| Gogs              | 8022 |   ssh    | CI      |        no        |   git.    |
| Jenkins           | 8023 |   http   | CI      |        no        |    ci.    |
| Mqtt              | 8030 |   http   | Hard    |        no        |   mqtt.   |
| Nodered           | 8031 |   http   | Hard    |        no        |  flows.   |
| Insolante         | 8032 |   http   | Hard    |        no        |   pcb.    |
| Octoprint         | 8033 |   http   | Hard    |        no        | printers. |
| Wordpress         | 8040 |   http   | Social  |        no        |   blog.   |
| Peertube          | 8041 |   http   | Social  |        no        |   video.  |
| Nexus             | 8050 |   http   | Storage |        no        |  nexus.   |
| Nexus docker pull | 8051 |   http   | Storage |        no        |  nexus.   |
| Nexus docker push | 8052 |   http   | Storage |        no        |  nexus.   |
| F-droid server    | 8053 |   http   | Storage |        no        |  fdroid.  |
| F-droid scp       | 8054 |   ssh    | Storage |        no        |  fdroid.  |
| Nextcloud         | 8055 |   http   | Storage |        no        |  drive.   |
| Grocy             | 8056 |   http   | Storage |        no        |  stock.   |
| Odoo              | 8057 |   http   | Storage |        no        |  erp.     |
| It-tools          | 8058 |   http   | Storage |        no        |  tools.   |
| Onlyoffice        | 8059 |   http   | Storage |        no        |  desk.    |
| Label-studio      | 8060 |   http   | ML      |        no        |  label.   |
| Audio-webui       | 8061 |   http   | ML      |        no        |  audio.   |
| Text-webui        | 8062 |   http   | ML      |        no        |  text.    |
| Text-webui-api    | 8063 |   http   | ML      |        no        |  text.    |
| Text-webui-stream | 8064 |   http   | ML      |        no        |  text.    |
| Image-webui       | 8065 |   http   | ML      |        no        |  text.    |


Playbooks parameters
====================

| Parameter           | Role    | Values          | Description                                                    |
| ------------------- |:-------:|:---------------:| -------------------------------------------------------------- |
| IDENTITY            |  common |       dev       | See identity description                                       |
| SKIP_SERVICES       |  common |       All       | List of service installation to skip                           |


Identity vars
=============

An identity is a directory where to store all specific variables. By default the identity is 'dev' and contains a vault file
and a vars file. A certs directory is also available for presentation purpose. Use the parameter IDENTITY to switch between them.

| Parameter           | Role    | Values              | Description                                                    |
| ------------------- |:-------:|:-------------------:| -------------------------------------------------------------- |
| DATACORE            |  common |      $HOME/data     | Infrastructure data directory, it will be backuped if enabled  |
| USER_NAME           |  common |       forge         | Default user name (will be created if doesn't exists)          |
| USER_MAIL           |  infra  | username@domain.tld | Default user email (for SSL certificate)                       |
| DOMAIN_NAME         |  infra  |          ""         | HTTPS and reverse proxy domain name                            |
| DEFAULT_ADMIN_NAME  |  infra  |          ""         | HTTPS and reverse proxy domain name                            |
| DOMAIN_CERT_NAME    |  infra  |          ""         | HTTPS and reverse proxy domain name                            |
| DOMAIN_CERT_KEY_NAME|  infra  |          ""         | HTTPS and reverse proxy domain name                            |

Vault file parameters
=====================

| Parameter               | Role       | Description                              |
| ----------------------- |:----------:| ---------------------------------------- |
| USER_PASS               |   common   | Default user password                    |
| ROOT_PASS               |   common   | Default root password                    |
| BACKUP_PASS             |   infra    | Default backup password                  |
| BACKUP_REMOTE_PASS      |   infra    | Default remote FTP password for backup   |
| PEERTUBE_DB_PASS        |   social   | Default database password for peertube   |
| WORDPRESS_DB_PASS       |   social   | Default database password for wordpress  |
| MQTT_READER_PASS        |   hard     | Default password for user with read acl  |
| MQTT_RW_PASS            |   hard     | Default password for user with write acl |
| JENKINS_PASS            |   ci       | Default jenkins admin user password      |
| NEXTCLOUD_PASS          |   storage  | Default nextcloud admin user password    |
| NEXUS_ADMIN_PASS        |   storage  | Default nexus admin user password        |
| ODOO_DB_PASS            |   storage  | Default database password for odoo       |

Vault for groovy secrets
-------------------------

| Parameter                |Description                              |
| ------------------------ |---------------------------------------- |
| ldap_domain              | ldap domain name (if set enable ldap)   |
| ldap_secure              | ldap switch to use ldaps                |
| ldap_remotes             | ldap remote url (comma separated list)  |
| ldap_username            | ldap user name                          |
| ldap_password            | ldap user passwords                     |
| ldap_search              | ldap base search string                 |
| ldap_admin_group         | ldap group used to get admin rights     |
| ldap_access_group        | ldap group used to get acces rights     |
| master2slave_username    | username used to connect slaves         |
| master2slave_private_key | Key used to connect slaves throught SSH |
| git_deploy_username      | username used to connect slaves         |
| git_deploy_private_key   | Key used to clone git repositories      |
| nexus_deploy_username    | credential to upload artifacts on nexus |
| nexus_deploy_password    | credential to upload artifacts on nexus |


Services description
====================

Some services are not skipable like https, homepage and portainer.  
MQTT and nodered services can be skipped by adding "domotic" in SKIP_SERVICES.  
Odoo is known as "erp" in the SKIP_SERVICES list.  
All others use the main container name (nexus, gogs, jenkins, peertube, wordpress, insolante, ...).  
Some services like jenkins, nexus, wordpress, peertube and odoo are not available on armv7.


Notes:
======

About SSL and traefik
---------------------

Let's Encrypt have a limit of registrable certificate per week.  
To get a new certificate onDemand should be set to true in traefik.tml.  
When a certificate is valid then it will be in acme.json with chmod=600 and must be saved.

If a bad gateway error occurs then wait a few moments to get the certificate renewal complete.  
The certificate is ciphered with the vault password.


About backup
------------

This system will create an archive and upload it to the specified FTP server in a directory under `FTP_ROOT/FORGE_MODE/`.  
By default it will keep the 3 latest backups.


About docker registry
---------------------
To login to the docker registry if there is no https (https://github.com/docker/distribution/issues/1874)  
Should not happen now with traefik.
Edit /etc/docker/daemon.json on your host and write:
```
{
  "insecure-registries":["registry.ip:8051", "registry.ip:8052"]
}
```

Restart docker daemon:
```
  sudo service docker restart
```


About passwords in the provided vault.yml file of dev identity
---------------------------------------------------------------

All password are 'test' except for root and the user created by ansible.


About fdroid
------------

Even if fdroid-server image allows to set a password for fdroid user we will use authorized_keys system.  
So create the file in `shared/fdroid_authorized_keys` with your public keys.


About Peertube
--------------

The Peertube image comes from my own fork on github so it will not be updated each time.  
WARNING: USER_MAIL is required.  
WARNING: admin user password is shown only in the docker logs (Keep in mind to connect with it and change the password ASAP).


About arm variant
------------------

Some services are not available on Arm 32bits (armv7l):

* Wordpress: mariadb is not compatible so the service become deactivated.
* Peertube: The arm image is build on an aarch64 machine so it is not compatible with armv7l now (maybe later).
* Jenkins: Ressources consumption is really high for this service, is is disabled on armv7.
* Nexus: Ressources consumption is really high for this service, is is disabled on armv7.


About ldap
----------

Nexus and Jenkins contains groovy scripts to connect them to an external active directory.
ldap_* variables must all be set to be able to use it in these services.
ldap_secure is used only for Nexus (not tested yet).
ldap_admin_group is used on Nexus and Jenkins but ldap_access_group is only used on Nexus.
Local account stay enabled only on Nexus (please use a strong password).

About audio-webui
-----------------

This service is built from the sources and need an Nvidia GPU to work.
Is not GPU is detected the service is not installed.


About label-studio
------------------

The string "@localhost" is appened to the default admin user as the default login
