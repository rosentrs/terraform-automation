provider "hcloud" {
  token = var.hcloud_token
}

esource "hcloud_ssh_key" "ssh_key" {
  name = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# VM aufsetzen
resource "hcloud_server" "webserver" {
  name        = "webserver"
  image       = "ubuntu-22.04"
  server_type = "cx11"

  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]

}

# Erstellen Sie den hcloud-Datenträger, der als Host-Volume verwendet wird
resource "hcloud_volume" "web_data" {
  name   = "web_data"
  server = hcloud_server.webserver.id
}

# Erstellen Sie eine Floating IP, um den Webserver von außerhalb erreichbar zu machen
resource "hcloud_floating_ip" "webserver_ip" {
  server = hcloud_server.webserver.id
}
