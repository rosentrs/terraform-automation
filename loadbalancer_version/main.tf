provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "ssh_key" {
  name      = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_server" "webserver" {
  count       = var.num_servers
  name        = "webserver${count.index}"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location = "nbg1"
  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]

}

resource "null_resource" "container_set_up" {
  depends_on = [ hcloud_server.webserver ]
  count = var.num_servers


  # Skript für Dockerinstallation übertragen
  provisioner "file" {
    source = "./dockersetup.sh"
    destination = "/tmp/dockersetup.sh"
    connection {
      type        = "ssh"
      host        = hcloud_server.webserver[count.index].ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }
  
  # 
  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod +x /tmp/dockersetup.sh",
      "bash /tmp/dockersetup.sh",
      "cd /tmp",
      "echo '<!DOCTYPE html><html><head><title>Webserver Greeting</title></head><body><p>Hello from Webserver ${count.index + 1}</p></body></html>' | sudo tee /tmp/index.html",
      "sudo docker build -t apache_image .",
      "sudo docker run -d -p 80:80 apache_image"
     ]
     connection {
      type        = "ssh"
      host        = hcloud_server.webserver[count.index].ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

resource "hcloud_load_balancer" "webserver_lb" {
  depends_on = [hcloud_server.webserver]

  name = "webserver-lb"
  load_balancer_type = "lb11"
  location = "nbg1"

}
resource "hcloud_load_balancer_target" "load_balancer_target" {
  depends_on = [ hcloud_load_balancer.webserver_lb ]
  count = var.num_servers
  type = "server"
  load_balancer_id = hcloud_load_balancer.webserver_lb.id
  server_id = hcloud_server.webserver[count.index].id
}
resource "hcloud_load_balancer_service" "load_balancer_service_http" {
  load_balancer_id = hcloud_load_balancer.webserver_lb.id
  protocol = "http"
}

provider "cloudflare" {
  email = "rosentreter.sophie@gmail.com"
  api_key = var.cloudflare_api_key
}
resource "cloudflare_record" "lab4_cloud_dns" {
  depends_on = [ hcloud_load_balancer.webserver_lb ]
  zone_id = var.cloudflare_zone_id
  name    = "lab4.cloud"
  value   = hcloud_load_balancer.webserver_lb.ipv4
  type    = "A"
  ttl     = 300
}
