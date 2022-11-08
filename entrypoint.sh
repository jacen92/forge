#!/bin/bash

# Required variables
# TARGET: name of the target system and host file will be overwritten.
# IDENTITY Name of the identity archive to load.
# VAULT_PASSWORD will be added to a file in the home in ~/.ansible-vault/forge if the file was not shared.

# required secrets
# $SHARED_DIRECTORY/ansible_key: will be used to connect to the remote system.
# $SHARED_DIRECTORY/vault_password: in some case the password must be provided in a file instead of an env var.
# $SHARED_DIRECTORY/identity_password: In the case the identity archive is encrypted
# $SHARED_DIRECTORY/$IDENTITY.zip: zip archive of an identity folder, should not be a flat archive.
# $SHARED_DIRECTORY/forge_authorized_keys; keys allowed to connect to the forge.
# $SHARED_DIRECTORY/fdroid_authorized_keys: keys allowed to send files to fdroid.

export ANSIBLE_HOST_KEY_CHECKING=False
export PATH=/home/$USER_NAME/.local/bin/:$PATH
export VAULT_PASSWORD_FILE=/home/$USER_NAME/.ansible-vault/forge

if [ ! -z "$TARGET" ]; then
  echo "Targetting: $TARGET"
  cat >/home/$USER_NAME/forge/hosts <<EOL
[forge]
$TARGET

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=root
EOL
else
  echo "ERROR: TARGET must be provided"
  exit 1
fi

if [ ! -z "$IDENTITY" ]; then
  if [ -f "$SHARED_DIRECTORY/$IDENTITY.zip" ]; then
    if [ -f "$SHARED_DIRECTORY/identity_password" ]; then
      echo "Use provided identity $IDENTITY with password"
      unzip -P "$(cat $SHARED_DIRECTORY/identity_password)" "$SHARED_DIRECTORY/$IDENTITY.zip" -d /home/$USER_NAME/forge/identity
    else
      echo "Use provided identity $IDENTITY"
      unzip "$SHARED_DIRECTORY/$IDENTITY.zip" -d /home/$USER_NAME/forge/identity
    fi
    echo "Replace identity name in setup_forge.yml"
    sed -i 's+IDENTITY: "dev"+IDENTITY: "'$IDENTITY'"+' /home/$USER_NAME/forge/setup_forge.yml
  else
    echo "ERROR: $IDENTITY.zip not found in $SHARED_DIRECTORY/"
    exit 2
  fi
else
  echo "Use default dev indentity"
fi

if [ -f "$SHARED_DIRECTORY/ansible_key" ]; then
  echo "Use provided ssh private key"
  cp $SHARED_DIRECTORY/ansible_key /home/$USER_NAME/.ssh/id_rsa
  chmod 400 /home/$USER_NAME/.ssh/id_rsa
else
  echo "ERROR: An ssh private key must be provided in $SHARED_DIRECTORY/ansible_key"
  exit 3
fi

if [ ! -z "$VAULT_PASSWORD" ]; then
  echo "Use provided password for the ansible vault of provided identity"
  echo "$VAULT_PASSWORD" > $VAULT_PASSWORD_FILE
else
  if [ -f "$SHARED_DIRECTORY/$IDENTITY_vault_password" ]; then
    echo "Use provided vault password file"
    cp $SHARED_DIRECTORY/$IDENTITY_vault_password $VAULT_PASSWORD_FILE
  else
    echo "Use default password for the ansible vault of dev identity"
    echo "password" > $VAULT_PASSWORD_FILE
  fi
fi

if [ -f "$SHARED_DIRECTORY/forge_authorized_keys" ]; then
  echo "Use provided forge_authorized_keys"
  cp $SHARED_DIRECTORY/forge_authorized_keys /home/$USER_NAME/forge/roles/common/files/authorized_keys
fi

if [ -f "$SHARED_DIRECTORY/fdroid_authorized_keys" ]; then
  echo "Use provided fdroid_authorized_keys"
  cp $SHARED_DIRECTORY/fdroid_authorized_keys /home/$USER_NAME/forge/roles/infra_storage/files/fdroid/authorized_keys
fi

cd /home/$USER_NAME/forge
time ansible-playbook --ssh-extra-args "-o ServerAliveInterval=50" -i hosts --vault-password-file $VAULT_PASSWORD_FILE setup_forge.yml
