#!/bin/bash
# Installiere Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Erstelle das Docker-Volume
sudo docker volume create website_volume

# Starte den Apache-Server als Docker-Container und binde das Host-Volume
sudo docker run -d \
  -p 80:80 \
  --name apache_container \
  -v website_volume:/var/www/html \
  httpd:latest