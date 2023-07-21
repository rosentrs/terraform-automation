# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}


# Create a server
resource "hcloud_server" "web" {
  name        = "my-server"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  user_data = "${file("userdata.sh")}"
  ssh_keys = [var.ssh_key_name]
  connection {
    user = "ubuntu"
    type = "ssh"
    private_key = file("~/.ssh/id_rsa")# TODO: Pfad referenzieren
    timeout = "2m"
  }
  provisioner "file" {
     source      = "upload"
     destination = "/home/ubuntu"
  }
}