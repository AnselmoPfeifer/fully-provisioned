#!/usr/bin/env bash

sudo -i << EOF
    set -x
    su postgres
    cd /var/lib/postgresql/
    psql -c "ALTER ROLE postgres WITH PASSWORD 'password';"
    exit
EOF

if [ ! -f /var/lib/postgresql/pg_<%= @replication_username %>.txt ]; then
  sudo -i << EOF
    set -x
    echo 'Creating a replication user!'
    su <%= @default_username %>
    cd /var/lib/postgresql/
    psql -c "CREATE USER replication REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD 'password';"
    touch pg_replication.txt
    exit
EOF
else
  echo 'Skipping replication user!'
fi