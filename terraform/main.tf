provider "hcloud" {
  token = var.hcloud_token
}

# Erstelle SSH-Schlüsselpaar (öffentlich/privat) lokal
resource "hcloud_ssh_key" "ssh_key" {
  name = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}



# Server mit generiertem SSH-Schlüssel erstellen
resource "hcloud_server" "webserver" {
  name        = "webserver"
  image       = "ubuntu-22.04"
  server_type = "cx11"

  ssh_keys = [
    hcloud_ssh_key.ssh_key.id 
  ]

  
  # apachesetup.sh sorgt dafür, dass Apache2 installiert und kofiguriert(firewallbasics, Virtualhost einrichten, Daten für die Seite an richtige Stelle packen) wird
  provisioner "file" {
    source      = "./apachesetup.sh"
    destination = "/tmp/apachesetup.sh" // Passe den Zielort an, wenn nötig
    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x apachesetup.sh", // Stelle sicher, dass die Datei ausführbar ist
      "bash /tmp/apachesetup.sh" // Führe das Skript aus
    ]

    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }

# Cloudflare Provider konfigurieren
provider "cloudflare" {
  email = "rosentreter.sophie@gmail.com"
  api_key = var.cloudflare_api_key
}

# DNS-Eintrag für "lab4.cloud" erstellen
resource "cloudflare_record" "lab4_cloud_dns" {
  #target = "lab4.cloud"
  name   = "lab4.cloud"
  value  = hcloud_server.webserver.ipv4_address
  type   = "A"
  ttl    = 300
  zone_id = var.cloudflare_zone_id

  # install_cert.sh installiert das TLS-Zertifikat, schreibt die ssl.conf und sorgt für den Redirect von http auf https
  provisioner "file" {
    source      = "install_cert.sh" // Lokaler Pfad zur install_cert.sh-Datei
    destination = "/tmp/install_cert.sh" // Passe den Zielort an, wenn nötig
    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  // Das Skript "install_cert.sh" auf dem Server ausführen
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_cert.sh", // Stelle sicher, dass die Datei ausführbar ist
      "bash /tmp/install_cert.sh" // Führe das Skript aus
    ]

    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

