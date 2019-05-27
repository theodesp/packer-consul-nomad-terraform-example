resource "digitalocean_droplet" "server" {
  count = "${var.server_count}"
  name  = "nomad-${count.index + 1}"
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

  tags = ["nomad"]

  provisioner "file" {
    source      = "${path.module}/scripts/system.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/server.hcl <<EOF
datacenter = "dc1"
bind_addr = "${self.ipv4_address_private}"
advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  serf = "${self.ipv4_address_private}:4648"
  rpc  = "${self.ipv4_address_private}:4647"
  http = "${self.ipv4_address_private}:4646"
}
server {
  enabled = true
  bootstrap_expect = ${var.server_count}
}
client {
  enabled = true
  options = {
    "driver.raw_exec.enable" = "1"
  }
}
consul {
  address = "${var.consul_cluster_ip}:8500"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
EOF
CMD
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/service.sh",
    ]
  }
}

output "public_ips" {
  value = "${list(digitalocean_droplet.server.*.ipv4_address)}"
}

output "private_ips" {
  value = "${list(digitalocean_droplet.server.*.ipv4_address_private)}"
}