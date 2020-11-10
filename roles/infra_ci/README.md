Ansible continuous integration role for the Infrastructure

Content
=======

* Gogs: version control system and project manager.
* Jenkins: service instanciation.
* Redmine: project management.


Notes:
======

To update jenkins go to https://updates.jenkins-ci.org/download/war/ adn copy the sha256 of the selected version.  
All required secrets are in the vaulted file.

To use git repository you need:
* to make a RSA key pair and add the private key in the vault_test.yml file in git_deploy_private_key.
* to set the public key to an user able to deploy the projet.
* to use the gogs provided ssh url to clone

In your job you can use the git plugin of share the key with "Use secret text(s) or file(s)".  
In this case you will need to set an environment var (like SSH_KEY_PATH) which will get the path to the file and use it to tell git to use it as identity.

```
alias git="GIT_SSH_COMMAND=\"ssh -i $SSH_KEY_PATH\" git $@"
git clone ssh://git@192.168.0.1:8022/tools/builders.git
```

The alias can be defined in your slave profile with a condition to set it if SSH_KEY_PATH is present.
To add a secret in credential add something in vars/main.yml to JENKINS_CREDENTIALS.
