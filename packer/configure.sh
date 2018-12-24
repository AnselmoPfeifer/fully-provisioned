#!/usr/bin/env bash

function installDependencies() {
    local JAVA_HOME='/usr/local/jdk'
sudo -i << EOF
    apt-get update --quiet
    wget --output-document=chef_12.20.3-1_amd64.deb https://packages.chef.io/files/stable/chef/12.20.3/ubuntu/14.04/chef_12.20.3-1_amd64.deb
    dpkg -i chef_12.20.3-1_amd64.deb && rm chef_12.20.3-1_amd64.deb &> /dev/null

    curl --silent --output /usr/local/openjdk-10.0.2_linux-x64_bin.tar.gz https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz
    mkdir -p /usr/local/openjdk-10.0.2
    tar -xvzf /usr/local/openjdk-10.0.2_linux-x64_bin.tar.gz -C /usr/local/openjdk-10.0.2 --strip-components=1 &>/dev/null
    ln -s /usr/local/openjdk-10.0.2 ${JAVA_HOME}
    rm /usr/local/openjdk-10.0.2_linux-x64_bin.tar.gz

    update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1
    update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1
    update-alternatives --set java "${JAVA_HOME}/bin/java"
    update-alternatives --set javac "${JAVA_HOME}/bin/javac"

    echo "JAVA_HOME=/usr/local/jdk" >> /etc/profile
    echo "export JAVA_HOME" >> /etc/profile
    source /etc/profile
EOF
}

function configureJenkinsUser() {
sudo -i << EOF
    mkdir /etc/chef /var/chef
    cp /tmp/authorized_keys /home/ubuntu/.ssh/authorized_keys
    chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys && chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

    echo 'json_attribs "/etc/chef/node.json"' > /etc/chef/solo.rb
    echo "%sudo  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo
    chmod 440 /etc/sudoers.d/sudo
EOF
}

installDependencies
configureJenkinsUser
