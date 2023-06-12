# Create a DigitalOcean database cluster
resource "digitalocean_database_cluster" "mysql_cluster" {
  name      = "flask-db2"
  engine    = "mysql"
  version   = "8"
  region    = "nyc3"
  size      = "db-s-1vcpu-1gb"
  node_count = 1

  provisioner "local-exec" {
    command = <<EOT
      python3 config-db.py ${digitalocean_database_cluster.mysql_cluster.host} ${digitalocean_database_cluster.mysql_cluster.password}
    EOT
  }
}
