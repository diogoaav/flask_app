terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

data "digitalocean_ssh_key" "terraform1" {
  name = "jump2"
}

provider "digitalocean" {
  token = var.do_token
}
