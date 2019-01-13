Ansible base role for the Forge host.

Content
=======

* User: Configure Forge main user.
* Dependencies: Install required dependencies in the Forge.
* Acces: Manager ssh keys and password to connect to the Forge.
* Info: Keep information about latest run of the playbook on the Forge

NOTES:
======

To keep access to the root user put your key in `tasks/files/authorized_keys`.
