Ansible base role for the Forge host.

Content
=======

* Info: Keep information about latest run of the playbook on the Forge
* Dependencies: Install required dependencies in the Forge.
* Docker: Install docker and tools and configure it.
* Security: Install and configure firewall in the Forge.
* Acces: Manager ssh keys and password to connect to the Forge.
* User: Configure Forge main user.

NOTES:
======

To keep access to the root user put your public key in `files/authorized_keys`.
