#!/bin/bash

# Installieren von Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Apache Konfig und Weseitenfiles in den docker container kopieren
sudo docker cp apache.conf apache_webserver:/etc/apache2/sites-available/000-default.conf
sudo docker cp website/ apache_webserver:/var/www/html/

sudo docker start apache_webserver
