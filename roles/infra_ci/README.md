Ansible continuous intergration role for the Infrastructure

Content
=======

* jenkins: service instanciation
* plugins: jenkins service plugins installation
* Gogs: version control system and project manager.


Notes:
======

To update jenkins go to https://updates.jenkins-ci.org/download/war/ adn copy the sha256 of the selected version

To use gogs repository you need:
* to make a RSA key pair
* to add a credential username&key to jenkins
* to set the public key yo the user
* to use the gogs provided ssh url to clone
