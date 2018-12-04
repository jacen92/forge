Ansible roles to setup infrastructure on the pi-gen image right after generation and the first boot.

Preparation
===========

Install ansible on the host and engrave the latest https://github.com/jacen92/pi-gen lite image.  
This image contains my public key for accessing root user directly.  
All roles are also available for x86_64.

Services
========

* backup: configuration of the DATACORE for incremental ciphered backups on remote FTP (freebox).
* traefik: HTTPS support and reverse proxy with domain name [https://hub.docker.com/r/arm32v6/traefik/].
* gogs: github like server, source storage (lighter than gitlab) [https://hub.docker.com/r/gogs/gogs-rpi/].


Used port
=========

| Service       | port | protocol | locally exposed | publicly exposed | subDomain |
| ------------- |:----:|:--------:|:---------------:|:----------------:|:---------:|
| traefik       | 80   |   http   |       yes       |        yes       |           |
| traefik       | 443  |   https  |       yes       |        yes       |           |
| traefik       | 8000 |   https  |       yes       |        no        |           |
| gogs          | 3000 |   http   |       yes       |        yes       |    git.   |
| gogs          | 8022 |   ssh    |       yes       |        yes       |           |


Playbooks parameters
====================

| Parameter           | Role    | Values                 | Description                                                               |
| ------------------- |:-------:|:----------------------:| ------------------------------------------------------------------------- |
| FEATURES            |  common |          All           | List of features to use                                                   |
| USER_NAME           |  common |          pi            | Default user name                                                         |
| DATACORE            |  common |      $HOME/data        | Infrastructure data directory, will be backuped if enabled                |
| BACKUP              |  infra  |  no\|create\|restore   | Define the backup mode when you run the playbook                          |
| BACKUP_DST          |  infra  |      test\|forge       | Define the backup source directory (where backups are stored on the FTP)  |
| FTP_URL             |  infra  |  "mafreebox.free.fr"   | Backup FTP url, here we send the backup to the freebox                    |
| FTP_USER            |  infra  |      "freebox"         | Backup FTP user, use default freebox user by default                      |
| DOMAIN_NAME         |  infra  |         ""             | HTTPS and reverse proxy domain name                                       |


Features description
====================

| Name          |  Arch  | Description                                                            |
| ------------- |:------:| ---------------------------------------------------------------------- |
| vault         |  All   | Add or update user ans services passwords                              |
| https         |  All   | Add or update traefik configuration (vault must be set)                |
| gogs          |  All   | Add or update gogs docker instance                                     |


Vault file parameters
=====================

| Parameter     | Role     | Description                                          |
| ------------- |:--------:| ---------------------------------------------------- |
| FTP_PASS      |  infra   | Backup FTP password                                  |
| USER_PASS     |  common  | Default user password                                |
| BACKUP_PASS   |  infra   | Duplicity backup on create or restore mode           |


Notes:
======

About SSL and traefik
---------------------

Let's Encrypt have a limit of registrable certificate per week.  
To get a new certificate onDemand should be set to true in traefik.tml.  
When a certificate is valid then it will be in acme.json with chmod=600 and must be saved.

If a bad gateway error occurs then wait a few moments to get the certificate renewal complete.  
The certificate is ciphered with the vault password.
