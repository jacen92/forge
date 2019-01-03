Ansible base role for the Infrastructure

Content
=======

firewall and fail2ban: protect from DOS and bruteforce attacks
HTTPS: reverse-proxy with HTTPS
Gogs: version control system


NOTES:
======

How to unban ip:

$ sudo fail2ban-client set $JAIL unbanip $IP

Where $IP is the ban ip you want to unban and jail is in [gogs_ssh]
