#!/bin/bash
sudo wget -O /usr/local/bin/terraformdownload https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip
cd /usr/local/bin
sudo unzip terraformdownload
cd /workspace/terraform-automation/terraform
#terraform init