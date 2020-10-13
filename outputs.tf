### Creates Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl",
  {
    droplet-ip = digitalocean_droplet.www-1.ipv4_address
    }
    )
  filename = "inventory"
}
