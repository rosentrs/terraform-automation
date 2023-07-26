#!/bin/bash

# Installiere Docker (falls nicht bereits installiert)
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y docker.io
fi

# Erstelle das Docker-Image
docker build -t mein-apache-image /path/to/website

# Starte den Docker-Container
docker run -d -p 80:80 mein-apache-image
