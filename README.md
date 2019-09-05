Ansible roles to setup infrastructure on the Raspberry Pi, the rock64 or any x86_64 computer running Debian or Ubuntu.

Preparation
===========

Installation on Raspberry pi
----------------------------

Install ansible on the host and engrave the latest https://github.com/jacen92/pi-gen lite image.
This image contains my public key for accessing root user directly.


Installation on Rock64
----------------------

Flash Ubuntu 1804 minimal Arm64 bits. And after boot log in with rock64 user.
The default image will not authorize access to root from ssh so we need to update the sshd_config.
Uncomment the section about authorized_keys and add yours inside /root/.ssh/authorized_keys.

Installation on x86_64
----------------------

All roles are also available for x86_64.


Services
========

infra:
------

* traefik: HTTPS support and reverse proxy with domain name [https://hub.docker.com/r/arm32v6/traefik/].
* portainer: Docker images manager [https://hub.docker.com/r/portainer/portainer/].


Continuous integration:
-----------------------

* gogs: github like server, source storage (lighter than gitlab) [https://hub.docker.com/r/gogs/gogs-rpi/].
* jenkins: The leading open source automation server [https://github.com/jenkinsci/docker].


Hardware interaction:
---------------------

* insolante: gerber to gcode converter (wrapper to pcb2gcode) [https://hub.docker.com/r/ngargaud/insolante].
* mqtt: Mosquitto broker for the Internet of Things [https://hub.docker.com/_/eclipse-mosquitto].
* nodered: Flow-based programming for the Internet of Things [https://hub.docker.com/r/nodered/node-red-docker/].
* octoprint: The snappy web interface for your 3D printer. [https://hub.docker.com/r/nunofgs/octoprint].


Social and media:
-----------------

* Wordpress: The WordPress rich content management system [https://hub.docker.com/_/wordpress/].
* Peertube: Federated video streaming platform [https://hub.docker.com/r/ngargaud/peertube].
* mStream: The easiest music streaming server available [https://hub.docker.com/r/linuxserver/mstream].


Storage:
--------

* nexus: Artifact manager and docker registry [https://github.com/sonatype/docker-nexus3].
* fdroid: Android application server [https://hub.docker.com/r/ngargaud/fdroid-server].
* nextcloud: Google drive alternative [https://hub.docker.com/_/nextcloud/].


Port listing (exposed from all docker containers)
=================================================

| Service           | port | protocol | Role    | publicly exposed | subDomain |
| ----------------- |:----:|:--------:|:-------:|:----------------:|:---------:|
| Traefik           | 80   |   http   | infra   |        yes       |           |
| Traefik           | 443  |   https  | infra   |        yes       |           |
| Traefik           | 8000 |   http   | infra   |        no        |           |
| Portainer         | 8010 |   http   | infra   |        no        |           |
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


Playbooks parameters
====================

| Parameter           | Role    | Values                 | Description                                                    |
| ------------------- |:-------:|:----------------------:| -------------------------------------------------------------- |
| FORGE_MODE          |  common |    test or forge       | Installation mode (a file vault_${FORGE_MODE} should exists)   |
| DATACORE            |  common |      $HOME/data        | Infrastructure data directory, it will be backuped if enabled  |
| FEATURES            |  common |          All           | List of features to use                                        |
| USER_NAME           |  common |          pi            | Default user name (will be created if doesn't exists)          |
| USER_MAIL           |  infra  |    username@domain     | Default user email (for SSL certificate)                       |
| DOMAIN_NAME         |  infra  |         ""             | HTTPS and reverse proxy domain name                            |


Features description
====================

| Name          |   Arch  | Description                                                            |
| ------------- |:-------:| ---------------------------------------------------------------------- |
| vault         |   All   | Unlock user and services passwords                                     |
| https         |   All   | Add or update traefik instance and configuration (vault must be set)   |
| domotic       |   All   | Add or update nodered and mosquitto docker instances                   |
| insolante     |   All   | Add or update insolante docker instance                                |
| octoprint     |   All   | Add or update octoprint docker instance                                |
| portainer     |   All   | Add or update portainer docker instance                                |
| wordpress     |   All   | Add or update wordpress and database docker instances                  |
| peertube      |   All   | Add or update Peertube docker instance (fr based on my github fork)    |
| mstream       |   All   | Add or update mStream docker instance                                  |
| gogs          |   All   | Add or update gogs docker instance                                     |
| jenkins       | not RPI | Add or update jenkins docker instance                                  |
| nexus         | not RPI | Add or update jenkins docker instance                                  |
| fdroid        |   All   | Add or update fdroid docker instance                                   |
| nextcloud     |   All   | Add or update extcloud docker instance                                 |


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
  "insecure-registries":["registry.ip:8027"]
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
