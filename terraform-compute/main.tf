# Create Droplet from snapshot
resource "digitalocean_droplet" "flask" {
  count   = 3
  name    = "droplet-flask-${count.index + 1}"
  region  = "nyc3"
  image   = "134490819"
  size    = "s-1vcpu-1gb"
  backups = false
  ipv6    = false
  ssh_keys  = [
    data.digitalocean_ssh_key.terraform1.fingerprint]
  tags    = ["flask-apps"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")  # Path to your private SSH key
    host        = self.ipv4_address
  }

#  provisioner "remote-exec" {
#    inline = [
#      "cd /root/app",
#      "chmod +x create_flask_service.sh",
#      "./create_flask_service.sh"
#    ]
#  }  
}

resource "digitalocean_loadbalancer" "public" {
  name   = "flask-lb-nyc3"
  region = "nyc3"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port    = 5000
    target_protocol = "http"
  }
  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_tag = "flask_apps"
}
