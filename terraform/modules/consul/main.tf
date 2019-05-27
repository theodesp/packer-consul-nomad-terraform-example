resource "digitalocean_droplet" "server" {
  count = "${var.server_count}"
  name  = "consul-${count.index + 1}"
  image = "${var.image}"
  size  = "${var.size}"
  region = "${var.region}"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

  tags = ["consul"]

  provisioner "file" {
    source      = "${path.module}/scripts/system.service"
    destination = "/tmp/consul.service"
  }

   provisioner "remote-exec" {
    inline = [
      "echo ${var.server_count} > /tmp/consul-server-count",
      "echo ${digitalocean_droplet.server.0.ipv4_address_private} > /tmp/consul-server-addr",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/service.sh",
    ]
  }
}

output "server_ip" {
  value = "${digitalocean_droplet.server.0.ipv4_address_private}"
}