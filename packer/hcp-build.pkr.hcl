packer {
  required_plugins {
    digitalocean = {
      version = ">=1.1.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

// Be sure to export your DIGITALOCEAN_TOKEN
// to your environment or use the below 'api_token'
// field.
// export API_TOKEN=YOUR_API_TOKEN

variable "api_token" {}

source "digitalocean" "example" {
  api_token        = var.api_token
  image            = "ubuntu-22-10-x64"
  region           = "nyc3"
  size             = "s-1vcpu-1gb"
  ssh_username     = "root"
  snapshot_regions = ["nyc3"]
}

build {
  sources = ["source.digitalocean.example"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
    user          = "root"
    use_proxy     = false
  }
}