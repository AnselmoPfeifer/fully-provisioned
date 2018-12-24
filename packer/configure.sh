#!/usr/bin/env bash

function installDependencies() {
sudo -i << EOF
    apt-get update --quiet
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common python-pip
    pip install awscli

    curl --silent --output chef_12.20.3-1_amd64.deb https://packages.chef.io/files/stable/chef/12.20.3/admin/14.04/chef_12.20.3-1_amd64.deb
    dpkg -i chef_12.20.3-1_amd64.deb && rm chef_12.20.3-1_amd64.deb &> /dev/null

    mkdir /etc/chef /var/chef
    cp /tmp/authorized_keys /home/admin/.ssh/authorized_keys
    chown admin:admin /home/admin/.ssh/authorized_keys
    chown admin:admin /home/admin/.ssh/authorized_keys
    echo 'json_attribs "/etc/chef/node.json"' > /etc/chef/solo.rb
EOF
}

installDependencies

