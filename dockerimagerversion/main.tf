provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "webserver" {
  name        = "webserver"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  
  provisioner "file" {
    source      = "deploy_website.sh"
    destination = "/tmp/deploy_website.sh"
    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy_website.sh",
      "/tmp/deploy_website.sh"
    ]
    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }
  
}

resource "hcloud_floating_ip" "webserver_ip" {
  type = "ipv4"
  server_id = hcloud_server.webserver.id
}

resource "hcloud_ssh_key" "ssh_key" {
  name      = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_server_ssh_key" "webserver_ssh_key" {
  server_id = hcloud_server.webserver.id
  ssh_key_id = hcloud_ssh_key.ssh_key.id
}

resource "hcloud_floating_ip_assignment" "webserver_ip_assignment" {
  floating_ip_id = hcloud_floating_ip.webserver_ip.id
  server_id = hcloud_server.webserver.id
}

provider "docker" {
  # Verwenden Sie hier die Zugangsdaten für Ihre Container-Registry
  # Alternativ können Umgebungsvariablen oder Dateien für die Authentifizierung verwendet werden
  # Weitere Informationen finden Sie in der Terraform-Dokumentation für den Docker-Provider
}

resource "docker_image" "apache_image" {
  name          = "./mein-apache-image"
  keep_locally  = true
}

resource "docker_container" "webserver_container" {
  name  = "webserver_container"
  image = docker_image.apache_image.latest
  ports {
    internal = 80
    external = 80
  }
}

output "server_ip" {
  value = hcloud_floating_ip.webserver_ip.floating_ip
}



##############################3
resource "null_resource" "docker_build" {
  provisioner "file" {
    content     = file("path/to/Dockerfile")  # Pfad zum Dockerfile auf dem Zielserver
    destination = "/path/to/Dockerfile"  # Zielort des Dockerfiles auf dem Zielserver
  }

  provisioner "file" {
    content     = file("path/to/website")  # Pfad zum Inhalt der Webseite auf dem Zielserver
    destination = "/path/to/website"  # Zielort des Inhalts der Webseite auf dem Zielserver
  }

  provisioner "remote-exec" {
    inline = [
      "cd /path/to",  # Wechseln Sie zum Verzeichnis, in dem das Dockerfile liegt
      "docker build -t mein-apache-image .",  # Docker-Image erstellen
      "docker run -d -p 80:80 mein-apache-image"  # Docker-Container starten
    ]

    connection {
      type        = "ssh"
      host        = hcloud_server.webserver.ipv4_address
      user        = "your-ssh-user"  # Benutzername für die SSH-Verbindung
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
