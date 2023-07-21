#!/bin/bash
apt-get update
apt-get install apache2 -y
cp /home/ubuntu/upload/index.html /var/www/html
chmod 644 /var/www/html/index.html

#Firewall setting
sudo ufw allow ssh
sudo ufw allow 80/tcp comment 'Allow Apache HTTP'
sudo ufw allow 443/tcp comment 'Allow Apache HTTPS'

systemctl enable apache2

sudo systemctl restart apache2