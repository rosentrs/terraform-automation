#!/bin/bash

# Setzen Sie hier den Domainnamen Ihrer Webseite ein
domain="lab4.cloud"

# Setzen Sie hier den Pfad zum Verzeichnis Ihrer Webseite ein
webroot="/var/www/html"

# Installieren des Apache2-Webserver und firewall erlaubt port 80 und 443
sudo apt update
sudo apt install -y apache2
sudo ufw allow 'Apache'
sudo ufw allow ssh
sudo ufw allow 80/tcp comment 'Allow Apache HTTP'
sudo ufw allow 443/tcp comment 'Allow Apache HTTPS'
sudo a2enmod rewrite
sudo systemctl enable apache2
sudo systemctl restart apache2

# Erstellen einer neuen VirtualHost-Konfigurationsdatei
cat > "/etc/apache2/sites-available/${domain}.conf" << EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $domain
    DocumentRoot $webroot

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Aktivieren Sie die VirtualHost-Konfiguration
sudo a2ensite ${domain}.conf

# Setzen Sie den Server-Name und Server-Admin in der Apache-Konfiguration
sudo sed -i "s/ServerName.*/ServerName $domain/" /etc/apache2/apache2.conf
sudo sed -i "s/ServerAdmin.*/ServerAdmin webmaster@$domain/" /etc/apache2/apache2.conf

# Starten Sie den Apache-Webserver
sudo systemctl start apache2


sudo rm /var/www/html/index.html
echo "indexhtml entfernt"
# Herunterladen der Webseite und Entpacken
sudo apt install -y unzip
sudo wget -O /tmp/website.zip https://html5up.net/dimension/download --no-check-certificate
sudo unzip -uo /tmp/website.zip -d $webroot

# Berechtigungen setzen
sudo chown -R www-data:www-data $webroot
sudo chmod -R 755 $webroot

# Neustart des Apache-Webservers
sudo systemctl restart apache2

echo "Die Webseite wurde erfolgreich eingerichtet und ist unter http://$domain erreichbar."
