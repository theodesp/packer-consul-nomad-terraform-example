#!/bin/bash

set -ex pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y unzip

echo "Fetching Nomad..."
mkdir -p /opt/nomad/data
mkdir -p /etc/nomad.d
mv /tmp/server.hcl /etc/nomad.d
NOMAD=0.9.1
machine_type=amd64
cd /tmp

echo "Installing Nomad..."
echo https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_${machine_type}.zip
curl -L -o nomad.zip https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_${machine_type}.zip
unzip nomad.zip > /dev/null
rm nomad.zip
mv nomad /usr/local/bin/nomad
chmod +x /usr/local/bin/nomad

cat >/tmp/nomad_flags << EOF
NOMAD_FLAGS="-server -data-dir /opt/nomad/data -config /etc/nomad.d"
EOF

echo "Installing Systemd service..."
mkdir -p /etc/systemd/system/nomad.d
chown root:root /tmp/nomad.service
mv /tmp/nomad.service /etc/systemd/system/nomad.service
chmod 0644 /etc/systemd/system/nomad.service
mkdir -p /etc/sysconfig/
mv /tmp/nomad_flags /etc/sysconfig/nomad
chown root:root /etc/sysconfig/nomad
chmod 0644 /etc/sysconfig/nomad

echo "using systemctl"
systemctl enable nomad.service
systemctl start nomad
