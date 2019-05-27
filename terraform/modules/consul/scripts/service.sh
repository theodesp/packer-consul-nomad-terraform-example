#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y unzip

echo "Fetching Consul..."
CONSUL=1.5.1
machine_type=amd64
cd /tmp
curl -L -o consul.zip https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_${machine_type}.zip

echo "Installing Consul..."
unzip consul.zip > /dev/null
rm consul.zip
chmod +x consul
mv consul /usr/local/bin/consul
mkdir -p /opt/consul/data
mkdir -p /var/consul

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')
BIND=`ifconfig eth1 | grep "inet" | awk '{ print $2 }' | head -n 1`

# Write the config to a temporary file
cat > config.json << EOF
{
    "bootstrap_expect": ${SERVER_COUNT},
    "datacenter": "Us-Central",
    "data_dir": "/var/consul",
    "domain": "consul",
    "enable_script_checks": true,
    "dns_config": {
        "enable_truncate": true,
        "only_passing": true
    },
    "enable_syslog": true,
    "encrypt": "vqebKbxW3znFGMcUg7PSvQ==",
    "leave_on_terminate": true,
    "log_level": "INFO",
    "rejoin_after_leave": true,
    "server": true,
    "start_join": [
        "${CONSUL_JOIN}"
    ],
    "ui": false
}
EOF

# Write the flags to a temporary file
cat > /tmp/consul_flags << EOF
CONSUL_FLAGS="-data-dir=/opt/consul.d/data -config-dir=/etc/consul.d/ -client=${BIND} -bind=${BIND}"
EOF

echo "Installing Systemd service..."
mkdir -p /etc/systemd/system/consul.d
chown root:root /tmp/consul.service
mv /tmp/consul.service /etc/systemd/system/consul.service
mkdir -p /etc/consul.d/
mv /tmp/config.json /etc/consul.d/config.json
chown root:root /etc/consul.d/config.json
chmod 0644 /etc/consul.d/config.json
chmod 0644 /etc/systemd/system/consul.service
mkdir -p /etc/sysconfig/
mv /tmp/consul_flags /etc/sysconfig/consul
chown root:root /etc/sysconfig/consul
chmod 0644 /etc/sysconfig/consul

echo "using systemctl"
systemctl enable consul.service
systemctl start consul