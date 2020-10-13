terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "1.22.2"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "Test1" {
  name = "Test1"
}

resource "digitalocean_droplet" "www-1" {
  image = "ubuntu-18-04-x64"
  name = "www-1"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.Test1.id
  ]
}
###########
# hack recommended by Hashi video to get SSH listening
###########
provisioner "remote-exec" {
  inline = ["sudo apt-get -qq install python -y"]

  connection {
    host = "${self.ipv4_address}"
    type = "ssh"
    user = "${var.ssh_user}"
    private_key = "${file('~/.ssh/id_rsa')}"
  }
}

provisioner "local-exec" {
  environment {
    PUBLIC_IP = "${self.ipv4_address}"
    PRIVATE_IP = "${self.ipv4_address_private}"
  }

  working_dir = "../Ansible/"
  command = "ansible-playbook -u root --private_key ${var.ssh_key_private} apache.yml -i '${digitalocean_droplet.www-1.ipv4_address}' "
}
