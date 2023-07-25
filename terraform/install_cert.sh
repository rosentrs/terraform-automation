#!/bin/bash

# Stop Apache to release port 80
sudo systemctl stop apache2
sudo apt-get update
sudo apt-get install -y socat
# Install acme.sh
curl https://get.acme.sh | sh

# Check if ECC certificate already exists
if sudo ~/.acme.sh/acme.sh --list | grep -q 'lab4.cloud_ecc'; then
  # Use ECC certificate
  sudo ~/.acme.sh/acme.sh --install-cert -d lab4.cloud \
      --ecc \
      #vllt wieder entfernen:
      --cert-file /etc/ssl/certs/lab4.cloud.cer\ 
      --key-file /etc/ssl/private/lab4_cloud.key \
      --fullchain-file /etc/ssl/certs/lab4_cloud.crt
else
  # Issue RSA certificate
  sudo ~/.acme.sh/acme.sh --issue -d lab4.cloud --standalone --server letsencrypt
  
  # Install RSA certificate
  sudo ~/.acme.sh/acme.sh --install-cert -d lab4.cloud \
      --cert-file /etc/ssl/certs/lab4.cloud.cer\
      --key-file /etc/ssl/private/lab4_cloud.key \
      --fullchain-file /etc/ssl/certs/lab4_cloud.crt
fi

# Start Apache again
sudo systemctl start apache2


# SSL-Modul aktivieren
sudo a2enmod ssl


# SSL-Konfiguration hinzufügen
sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/default-ssl.conf
<VirtualHost _default_:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/lab4.cloud.cer
    SSLCertificateKeyFile /etc/ssl/private/lab4_cloud.key
</VirtualHost>
EOL'

# Ersetzen Sie "/path/to/your_certificate.crt" durch den Pfad zu Ihrem SSL/TLS-Zertifikat
# und "/path/to/your_private_key.key" durch den Pfad zum privaten Schlüssel.

# SSL-Konfiguration aktivieren
sudo a2ensite default-ssl

# Apache-Webserver neu starten
sudo systemctl restart apache2