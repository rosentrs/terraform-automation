provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "webserver" {
  name        = "webserver"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  
  # Hier weitere Konfigurationen für den Server hinzufügen, falls nötig
  
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
  name          = "mein-docker-registry/mein-apache-image"
  keep_locally  = false
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
####################################
resource "hcloud_server" "webserver" {
  # ... andere Konfigurationen für den hcloud_server ...

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
