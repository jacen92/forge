Ansible role for the storage

Content
=======

on ARM
nexus: raw and docker image storage.
fdroid: android application store server.
portainer: docker machine web interface.

Notes
=====

on ARM
- 8030:5000 => Nexus.
- 8027 and 8028 => docker registry ports on nexus
- 8031 and 8032 => fdroid http and scp ports
- 8029:9000 => portainer
