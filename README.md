Ansible roles to setup infrastructure on the Raspberry Pi, the rock64 or any x86_64 computer running Debian or Ubuntu.

Preparation
===========

Host
----

Install ansible and edit the hosts file to set the correct IP of your target(s).  
Edit the setup_forge.yml file to add required features and some information about the new forge like the user, your mail and domain, ...  
Edit the vault_test.yml file to set your passwords (the default password to edit it is "password", remember to change it)

```
EDITOR=nano ansible-vault edit vault_test.yml
```

Target
------

Flash your image or install an OS on the target.  
The default image may not authorize access to root from ssh so we need to update the sshd_config.  
Add your public key inside /root/.ssh/authorized_keys (this playbook is using root access by default).  
Some roles are not available for ARM 32 bits (see the table below).  
When your access is set up you just have to do (it will ask for the vault file password):

```
time ansible-playbook -i hosts --ask-vault-pass setup_forge.yml
# or with a file containing the passwords
time ansible-playbook -i hosts --vault-password-file ~/.ansible-vault/test setup_forge.yml
```


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
* mStream: The easiest music streaming server available [https://hub.docker.com/r/linuxserver/mstream].

![Renderer screenshot](/documents/screenshots/social.png)

Storage:
--------

* nexus: Artifact manager and docker registry [https://github.com/sonatype/docker-nexus3].
* fdroid: Android application server [https://hub.docker.com/r/ngargaud/fdroid-server].
* nextcloud: Google drive alternative [https://hub.docker.com/_/nextcloud/].
* Odoo: (formerly known as OpenERP) is a suite of open-source business apps [https://hub.docker.com/_/odoo].

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
| Gogs              | 8021 |   http   | CI      |        yes       |   git.    |
| Gogs              | 8022 |   ssh    | CI      |        yes       |   git.    |
| Jenkins           | 8023 |   http   | CI      |        no        |    ci.    |
| Mqtt              | 8030 |   http   | Hard    |        no        |   mqtt.   |
| Nodered           | 8031 |   http   | Hard    |        no        |  flows.   |
| Insolante         | 8032 |   http   | Hard    |        no        |   pcb.    |
| Octoprint         | 8033 |   http   | Hard    |        no        | printers. |
| Wordpress         | 8040 |   http   | Social  |        no        |   blog.   |
| Peertube          | 8041 |   http   | Social  |        no        |   video.  |
| mStream           | 8042 |   http   | Social  |        no        |   music.  |
| Nexus             | 8050 |   http   | Storage |        no        |  nexus.   |
| Nexus docker pull | 8051 |   http   | Storage |        no        |  nexus.   |
| Nexus docker push | 8052 |   http   | Storage |        no        |  nexus.   |
| F-droid server    | 8053 |   http   | Storage |        no        |  fdroid.  |
| F-droid scp       | 8054 |   ssh    | Storage |        no        |  fdroid.  |
| Nextcloud         | 8055 |   http   | Storage |        no        |  drive.   |
| Odoo              | 8056 |   http   | Storage |        no        |  erp.   |


Playbooks parameters
====================

| Parameter           | Role    | Values                 | Description                                                    |
| ------------------- |:-------:|:----------------------:| -------------------------------------------------------------- |
| FORGE_MODE          |  common |    test or forge       | Installation mode (a file vault_${FORGE_MODE} should exists)   |
| DATACORE            |  common |      $HOME/data        | Infrastructure data directory, it will be backuped if enabled  |
| SKIP_SERVICES       |  common |         All            | List of service installation to skip                           |
| USER_NAME           |  common |          pi            | Default user name (will be created if doesn't exists)          |
| USER_MAIL           |  infra  |    username@domain     | Default user email (for SSL certificate)                       |
| DOMAIN_NAME         |  infra  |          ""            | HTTPS and reverse proxy domain name                            |


Features description
====================

Some services are not skipable like https, netdata and portainer.

| Name          |    Arch   | Description                                                          |
| ------------- |:---------:| -------------------------------------------------------------------- |
| https         |    All    | Add or update traefik instance and configuration (vault must be set) |
| portainer     |    All    | Add or update portainer docker instance                              |
| netdata       |    All    | Add or update netdata docker instance                                |
| domotic       |    All    | Add or update nodered and mosquitto docker instances                 |
| insolante     |    All    | Add or update insolante docker instance                              |
| octoprint     |    All    | Add or update octoprint docker instance                              |
| wordpress     | Not armv7 | Add or update wordpress and database docker instances                |
| peertube      | Not armv7 | Add or update Peertube docker instance (fr based on my github fork)  |
| mstream       |    All    | Add or update mStream docker instance                                |
| gogs          |    All    | Add or update gogs docker instance                                   |
| jenkins       | Not armv7 | Add or update jenkins docker instance                                |
| nexus         | Not armv7 | Add or update jenkins docker instance                                |
| fdroid        |    All    | Add or update fdroid docker instance                                 |
| nextcloud     |    All    | Add or update extcloud docker instance                               |
| erp           | Not armv7 | Add or update Odoo and database docker instance                      |


Vault file parameters
=====================

| Parameter               | Role       | Description                              |
| ----------------------- |:----------:| ---------------------------------------- |
| USER_PASS               |   common   | Default user password                    |
| ROOT_PASS               |   common   | Default root password                    |
| BACKUP_PASS             |   infra    | Default backup password                  |
| BACKUP_REMOTE_PASS      |   infra    | Default remote FTP password for backup   |
| MSTREAM_PASS            |   social   | Default mStream admin user password      |
| PEERTUBE_DB_PASS        |   social   | Default database password for peertube   |
| WORDPRESS_DB_PASS       |   social   | Default database password for wordpress  |
| MQTT_READER_PASS        |   hard     | Default password for user with read acl  |
| MQTT_RW_PASS            |   hard     | Default password for user with write acl |
| JENKINS_PASS            |   ci       | Default jenkins admin user password      |
| NEXTCLOUD_PASS          |   storage  | Default nextcloud admin user password    |
| NEXUS_ADMIN_PASS        |   storage  | Default nexus admin user password        |
| ODOO_DB_PASS            |   storage  | Default database password for odoo       |

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


About passwords in vault_test.yml
---------------------------------

All password are 'test' except for root and the user created by ansible.


About fdroid
------------

Even if fdroid-server image allows to set a password for fdroid user we will use authorized_keys system.  
So update the file in `roles/infra_storage/tasks/files/fdroid/authorized_keys` with your public keys.


About Peertube
--------------

The Peertube image comes from my own fork on github so it will not be updated each time.  
WARNING: USER_MAIL is required.  
WARNING: admin user password is shown only in the docker logs (Keep in mind to connect with it and change the password ASAP).


About arm variant
------------------

Some services are not available on Raspberry (armv7l):

* Wordpress: mariadb is not compatible so the service become deactivated.
* Peertube: The arm image is build on an aarch64 machine so it is not compatible with armv7l now (maybe later).
* Jenkins: Ressources consumption is really high for this service, is is disabled on armv7.
* Nexus: Ressources consumption is really high for this service, is is disabled on armv7.
