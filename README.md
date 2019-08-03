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
Uncomment the section about authorized_keys and add your inside /root/.ssh/authorized_keys.

Installation on x86_64
----------------------

All roles are also available for x86_64.


Services
========

* traefik: HTTPS support and reverse proxy with domain name [https://hub.docker.com/r/arm32v6/traefik/].
* gogs: github like server, source storage (lighter than gitlab) [https://hub.docker.com/r/gogs/gogs-rpi/].
* insolante: gerber to gcode converter (wrapper to pcb2gcode) [https://hub.docker.com/r/ngargaud/insolante].
* nodered: Flow-based programming for the Internet of Things [https://hub.docker.com/r/ngargaud/insolante].
* octoprint: The snappy web interface for your 3D printer. [https://hub.docker.com/r/nunofgs/octoprint].
* jenkins: The leading open source automation server [https://github.com/jenkinsci/docker].
* registry: Official docker registry [https://hub.docker.com/r/registry/].
* registry-ui: Registry front-end and authentication proxy [https://hub.docker.com/r/joxit/docker-registry-ui/].
* portainer: Docker images manager [https://hub.docker.com/r/portainer/portainer/].
* nexus: Artifact manager and docker registry [https://github.com/sonatype/docker-nexus3].
* fdroid: Android application server [https://hub.docker.com/r/ngargaud/fdroid-server].
* mStream: The easiest music streaming server available [https://hub.docker.com/r/linuxserver/mstream].
* Peertube: Federated video streaming platform [https://hub.docker.com/r/ngargaud/peertube].
* Wordpress: The WordPress rich content management system [https://hub.docker.com/_/wordpress/].


Used port
=========

| Service       | port | protocol | locally exposed | publicly exposed | subDomain |
| ------------- |:----:|:--------:|:---------------:|:----------------:|:---------:|
| traefik       | 80   |   http   |       yes       |        yes       |           |
| traefik       | 443  |   https  |       yes       |        yes       |           |
| traefik       | 8000 |   https  |       yes       |        no        |           |
| gogs          | 3000 |   http   |       yes       |        yes       |    git.   |
| gogs          | 8022 |   ssh    |       yes       |        yes       |           |
| insolante     | 8023 |   http   |       yes       |        no        |   pcb.    |
| nodered       | 8024 |   http   |       yes       |        no        |  flows.   |
| octoprint     | 8025 |   http   |       yes       |        no        | printers. |
| jenkins       | 8026 |   http   |       yes       |        no        |    ci.    |
| registry      | 8027 |   http   |       no        |        no        |           |
| registry-ui   | 8028 |   http   |       yes       |        no        |           |
| portainer     | 8029 |   http   |       yes       |        no        |           |
| nexus         | 8030 |   http   |       yes       |        no        |  nexus.   |
| nexus pull    | 8027 |   http   |       yes       |        no        |           |
| nexus push    | 8028 |   http   |       yes       |        no        |           |
| fdroid server | 8031 |   http   |       yes       |        no        |  fdroid.  |
| fdroid scp    | 8032 |   ssh    |       yes       |        no        |           |
| mStream       | 8033 |   http   |       yes       |        no        |   music.  |
| Peertube      | 8034 |   http   |       yes       |        no        |   video.  |
| wordpress     | 8035 |   http   |       yes       |        no        |   blog.   |


Playbooks parameters
====================

| Parameter           | Role    | Values                 | Description                                                               |
| ------------------- |:-------:|:----------------------:| ------------------------------------------------------------------------- |
| FORGE_MODE          |  common |      test|forge        | Installation mode                                                         |
| FEATURES            |  common |          All           | List of features to use                                                   |
| USER_NAME           |  common |          pi            | Default user name                                                         |
| USER_MAIL           |  common |    username@domain     | Default user email for certificate                                        |
| DATACORE            |  common |      $HOME/data        | Infrastructure data directory, will be backuped if enabled                |
| DOMAIN_NAME         |  infra  |         ""             | HTTPS and reverse proxy domain name                                       |


Features description
====================

| Name          |   Arch  | Description                                                            |
| ------------- |:-------:| ---------------------------------------------------------------------- |
| vault         |   All   | Unlock user and services passwords                                     |
| https         |   All   | Add or update traefik configuration (vault must be set)                |
| gogs          |   All   | Add or update gogs docker instance                                     |
| insolante     |   All   | Add or update insolante docker instance                                |
| nodered       |   All   | Add or update nodered docker instance                                  |
| octoprint     |   All   | Add or update octoprint docker instance                                |
| jenkins       | not RPI | Add or update jenkins docker instance                                  |
| registry      |   ARM   | Add or update docker registry node                                     |
| registry-ui   |   ARM   | Add or update docker registry-ui node                                  |
| portainer     |   All   | Add or update portainer docker instance                                |
| nexus         | not RPI | Add or update jenkins docker instance                                  |
| fdroid        |   All   | Add or update fdroid docker instance                                   |
| mstream       |   All   | Add or update mStream docker instance                                  |
| peertube      |   All   | Add or update Peertube docker instance (fr based on my github fork)    |
| wordpress     |   All   | Add or update wordpress and database docker instances                  |


Vault file parameters
=====================

| Parameter               | Role       | Description                              |
| ----------------------- |:----------:| ---------------------------------------- |
| USER_PASS               |   common   | Default user password                    |
| ROOT_PASS               |   common   | Default root password                    |
| BACKUP_PASS             |   common   | Default backup password                  |
| BACKUP_REMOTE_PASS      |   common   | Default FTP password for backup          |
| JENKINS_PASS            |   jenkins  | Default jenkins admin user password        |
| MSTREAM_PASS            |   media    | Default mStream admin user password        |
| PEERTUBE_DB_PASS        |   media    | Default peertube database admin password   |
| WORDPRESS_DB_PASS       |   infra    | Default database password for wordpress    |


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

About fdroid
------------

Even if fdroid-server image allows to set a password for fdroid user we will use authorized_keys system.
So update the file in `roles/infra_storage/tasks/files/fdroid/authorized_keys` with your public keys.


About Peertube
--------------

The Peertube image comes from my own fork on github so it will not be updated each time.
WARNING: USER_MAIL is required.
WARNING: admin user password is shown only in the docker logs (Keep in mind to connect with it and change the password ASAP).
