#!/bin/bash

set -ex pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y unzip

if [ "$TARGET" == "consul" ]; then
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

elif [ "$TARGET" == "nomad" ]; then
    echo "Fetching Nomad..."
    mkdir -p /opt/nomad/data
    mkdir -p /etc/nomad.d
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
else
    exit
fi
