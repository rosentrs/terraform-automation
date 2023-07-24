#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo ufw allow 'Apache'
sudo ufw allow ssh
sudo ufw allow 80/tcp comment 'Allow Apache HTTP'
sudo ufw allow 443/tcp comment 'Allow Apache HTTPS'
sudo a2enmod rewrite
sudo sudo wget -O /var/www/download https://html5up.net/dimension/download
sudo apt get install unzip
sudo unzip /var/www/download
sudo systemctl enable apache2
sudo systemctl restart apache2