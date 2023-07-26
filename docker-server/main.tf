provider "hcloud" {
  token = var.hcloud_token
}

# Erstellen Sie einen hcloud Server
resource "hcloud_server" "webserver" {
  name        = "webserver"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  ssh_keys    = [
    hcloud_ssh_key.ssh_key.id 
  ]
}

# Erstellen Sie ein Host-Volume für die Website-Dateien
resource "hcloud_volume" "website_volume" {
  name       = "website_volume"
  size       = 10  # Größe des Volumes in GB
  automount  = true
  format     = "ext4"  # Dateisystem-Format
}

# Verbinden Sie das Volume mit dem Server
resource "hcloud_server_volume_attachment" "volume_attachment" {
  server_id = hcloud_server.webserver.id
  volume_id = hcloud_volume.website_volume.id
}

# Hängen Sie das Volume im Server als /var/www/html
# an, um die Website-Dateien zu speichern
resource "hcloud_floating_ip" "webserver_ip" {
  type = "ipv4"
}

resource "hcloud_floating_ip_assignment" "webserver_ip_assignment" {
  floating_ip_id = hcloud_floating_ip.webserver_ip.id
  server_id      = hcloud_server.webserver.id
}


resource "null_resource" "docker_script" {
provisioner "file" {
    source      = "./docker_script.sh"
    destination = "/tmp/docker_script.sh" // Passe den Zielort an, wenn nötig
    connection {
    type        = "ssh"
    host        = hcloud_floating_ip.webserver_ip.floating_ip  # Verwenden Sie die Floating IP des Servers
    user        = "root"
    private_key = file("~/.ssh/id_rsa")  # Passe den Pfad zum privaten SSH-Schlüssel an
  }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x docker_script.sh", // Stelle sicher, dass die Datei ausführbar ist
      "bash /tmp/docker_script.sh" // Führe das Skript aus
    ]

    connection {
    type        = "ssh"
    host        = hcloud_floating_ip.webserver_ip.floating_ip  # Verwenden Sie die Floating IP des Servers
    user        = "root"
    private_key = file("~/.ssh/id_rsa")  # Passe den Pfad zum privaten SSH-Schlüssel an
  }
  }
}
