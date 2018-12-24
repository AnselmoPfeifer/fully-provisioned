#!/usr/bin/env bash 
set -e -x

sudo -i << EOF
  su postgres
  psql -c "select pg_start_backup('initial_backup');"
  rsync -cva --inplace --exclude=*pg_xlog* --exclude=recovery.conf /data/postgresql/ 192.168.1.112:/data/postgresql/
  psql -c "select pg_stop_backup();"
  ssh postgres@192.168.1.112 'sudo service postgresql restart'
EOF
