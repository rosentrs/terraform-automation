#!/bin/bash

# terraform installieren
sudo wget -O /usr/local/bin/terraformdownload https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip
cd /usr/local/bin
sudo unzip terraformdownload
cd /workspace/terraform-automation/terraform

# ssh keypair generieren und richtig ablegen

# Prüfen, ob das .ssh-Verzeichnis existiert
if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
fi

# Prüfen, ob ein SSH-Schlüsselpaar bereits vorhanden ist
if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ]; then
  echo "Ein SSH-Schlüsselpaar existiert bereits."
else
  # Generiere ein neues SSH-Schlüsselpaar
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  echo "Ein neues SSH-Schlüsselpaar wurde erstellt und unter ~/.ssh/id_rsa gespeichert."
fi

