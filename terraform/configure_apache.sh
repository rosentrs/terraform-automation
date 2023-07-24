#!/bin/bash

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default.conf
sudo sed -i 's/:80>/:80>\n\tRewriteEngine On\n\tRewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]/' /etc/apache2/sites-available/default.conf
sudo a2ensite default.conf
sudo a2enmod ssl
sudo systemctl restart apache2
