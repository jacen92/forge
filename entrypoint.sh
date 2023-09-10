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
export PATH=/home/$USER_NAME/.local/bin/:/home/$USER_NAME/mkcert:$PATH
export VAULT_PASSWORD_FILE=/home/$USER_NAME/.ansible-vault/forge

# remove existing template in case an identity with dev name is used
rm -rf /home/$USER_NAME/forge/identity/dev

make_missing_cert() {
  export CAROOT="$SHARED_DIRECTORY/rootCA.pem"
  echo "Using custom certificate authority and export mkcert and rootCA"
  cp $(which mkcert) $SHARED_DIRECTORY
  mkcert -install

  if [ ! -f "/home/$USER_NAME/forge/identity/$IDENTITY/certs/default-key.pem" ]; then
    echo "Creating default certificates for $TARGET"
    mkcert $TARGET
    mv $TARGET-key.pem /home/$USER_NAME/forge/identity/$IDENTITY/certs/default-key.pem
    mv $TARGET.pem /home/$USER_NAME/forge/identity/$IDENTITY/certs/default.pem

    sed -i 's+DOMAIN_CERT_NAME: ""+DOMAIN_CERT_NAME: "default.pem"+' /home/$USER_NAME/forge/identity/$IDENTITY/vars.yml
    sed -i 's+DOMAIN_CERT_KEY_NAME: ""+DOMAIN_CERT_KEY_NAME: "default-key.pem"+' /home/$USER_NAME/forge/identity/$IDENTITY/vars.yml

    echo "Updating identity in $SHARED_DIRECTORY/$IDENTITY.zip"
    cd /home/$USER_NAME/forge/identity/ && zip -r $SHARED_DIRECTORY/$IDENTITY.zip $IDENTITY && cd -
  else
    echo "Using existing default certificate"
  fi
}

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
    if [ $(ls -1 /home/$USER_NAME/forge/identity/$IDENTITY/certs/*.pem 2>/dev/null | wc -l) != 0 ]; then
      echo "Use provided pem certificates"
    else
      if [ $(ls -1 /home/$USER_NAME/forge/identity/$IDENTITY/certs/*.crt 2>/dev/null | wc -l) != 0 ]; then
        echo "Use provided crt certificates"
      else
        make_missing_cert
      fi
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
