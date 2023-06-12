How to use Terraform, Packer and Ansible with DigitalOcean
==================

This is an example of how to use open source tools to provisioning and configuring DigitalOcean resources.

In this tutorial, you will create a Flask blog app, running in 3 droplets behind a LB connected to a managed MySQL DB in NYC3:

  - Terraform will be used to create a managed MySQL DB, we will use a "local-exec" provisioner to run a python script that configures and add some data to the DB;
  - Packer will create a droplet, use an Ansible provisioner to configure the flask application and will take a snapshot that will be used to create our fleet of droplets;
  - Terraform will then create 3 droplets and one load-balancer in NYC3 region.

Requirements
------------

-	Terraform
-	Ansible
-	Packer

Building The Tutorial
---------------------

Clone repository to the machine you will run the tutorial from:

```sh
git clone https://github.com/diogoaav/flask_app.git
```

1- Creating the Managed DB with Terraform
---------------------

Enter the terraform-db directory and create a terraform.tfvars file and include your DO token:

```sh
cd flask_app/terraform-db
export DIGITALOCEAN_TOKEN="YOUR_DO_TOKEN"
```

Initiate Terraform and apply the config, this command will provision the DB in aproximately 5 min.

```sh
terraform init
terraform apply -var "do_token=${DIGITALOCEAN_TOKEN}"
```

After terraform succesfully deploy the MySQL DB, get the DB connections details with the command below:

```sh
more terraform.tfstate
```

2- Creating the Wordpress image with Packer and Ansible
---------------------

In this step, we will use packer to create a wordpress image that will be used by Terraform later. Packer create a droplet, uses Ansible provisioner to install and configure relevant packages (PIP, FLASK). You can check the Ansible playbook at /ansible/playbook.yml.

Edit the Ansible playbook variable file in the wordpress/vars folder and include your managed DB details:

```sh
nano ../packer/ansible/vars/default.yml
```

```sh
#MySQL Settings
mysql_password: "YOUR_PASSWORD"
mysql_host: "YOUR_DB_URL"
```

Go to the packer folder and create a variables.auto.pkrvars.hcl file and include your API token:

```sh
cd ../packer
echo 'api_token = "YOUR_API_TOKEN"' > variables.auto.pkrvars.hcl
```

Execute packer, make sure you are in the same directory as the .hcl files:

```sh
packer init .
packer build .
```

Packer will take a few minutes to create a droplet, apply the terraform configuration using the Ansible provisioner, shutdown the droplet and creating a new image from that droplet.

Make sure you save the snapshot ID, that will be used to create the droplet in the next step.

3- Starting a new droplet from the image with Terraform
---------------------

Enter the terraform-droplet directory and create a terraform.tfvars file and include your DO token:

```sh
cd ../terraform-compute
```

Update your main.tf file with the correct snapshot id created in the previous step and configure the local path to your ssh private key that will be used to access this droplet.

```sh
vim main.tf
```

```sh
# Create Droplet from snapshot
resource "digitalocean_droplet" "flask" {
  count   = 3
  name    = "droplet-flask-${count.index + 1}"
  region  = "nyc3"
  image   = "MY-SNAPSHOT-ID"
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
```

Update your provider.tf file with the with the name of your ssh configured at DO cloud panel.

```sh
vim provider.tf
```

```sh
data "digitalocean_ssh_key" "terraform1" {
  name = "MY-SSH-KEY-NAME"
}
```

Execute terraform:

```sh
terraform init
terraform apply -var "do_token=${DIGITALOCEAN_TOKEN}"
```

4- Teardown instructions
---------------------

```sh
terraform destroy -var "do_token=${DIGITALOCEAN_TOKEN}"
```

```sh
cd ../terraform-db
terraform destroy -var "do_token=${DIGITALOCEAN_TOKEN}"
```