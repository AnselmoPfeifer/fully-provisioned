#!/usr/bin/env bash

set -e
BUCKET_NAME='devops-chef-us'

# the host ip address
LIST_HOST_ADDRESS=(
    192.168.1.110
    192.168.1.111
    192.168.1.112
)

LIST_HOST_NAME=(
    app-server
    slave-database
    master-database
)

function chefProvision() {
    local serverName=${1} # slave-database / master-database / app-server

    aws s3 s3://${BUCKET_NAME}/cookbooks/cookbooks_master.tar.gz .
    aws s3 cp s3://${BUCKET_NAME}/${2}.json .

    cp resources/solo.rb /etc/chef/
    cp ${2}.json /etc/chef/
    tar -xvzf cookbooks_master.tar.gz
    mv target/cookbooks /var/chef/
    sudo chef-solo /etc/chef/node.json --legacy-mode
}

function hostConnect() {
    for ip in ${LIST_HOST_ADDRESS[@]}; do
        for hostName in ${LIST_HOST_NAME[@]}; do
            ssh ubuntu@${ip} "${chefProvision} ${hostName}"
        done
    done
}


hostConnect