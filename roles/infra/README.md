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

$ export JAIL=ssh_gogs
$ export IP=192.168.0.20
$ sudo fail2ban-client set $JAIL unbanip $IP

Where $IP is the ban ip you want to unban and JAIL is in [gogs_ssh, gogs_ssh_scan]

When I am testing:

$ sudo fail2ban-client unban --all
