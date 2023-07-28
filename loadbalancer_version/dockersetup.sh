#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -qq ca-certificates curl gnupg
sudo install -qq -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin        

# Der Text, der in die Datei Dockerfile geschrieben werden soll
dockerfile_text=$(cat <<EOF
FROM httpd:latest

COPY . /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]

EOF
)

# Schreibe den Text in die Datei Dockerfile
echo "$dockerfile_text" > Dockerfile
mv ./Dockerfile /tmp/Dockerfile
echo "Der Text wurde in die Datei Dockerfile geschrieben."
