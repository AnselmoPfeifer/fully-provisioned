#!/usr/bin/env bash
set -e

LIST=(
    app-server-ubuntu-1604
    data-base-slave-ubuntu-1604
    data-base-master-ubuntu-1604
)

berks install
berks update

for server in ${LIST[@]}; do
    kitchen list ${server}
    kitchen converge ${server}
done