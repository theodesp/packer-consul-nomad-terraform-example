# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

module "consul" {
  source = "./modules/consul"
  size = "1gb"
  image = "ubuntu-18-04-x64"
  pvt_key = "${var.pvt_key}"
  server_count = 2
  ssh_fingerprint = "${var.ssh_fingerprint}"
}

module "nomad" {
  source            = "./modules/nomad"
  image = "ubuntu-18-04-x64"
  size = "1gb"
  pvt_key = "${var.pvt_key}"
  server_count = 1
  consul_cluster_ip = "${module.consul.server_ip}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
}