#
# Cookbook:: fully-chef
# Recipe:: replication-postresql
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

execute 'usermod -aG sudo postgres'

if node['postgresql']['is_master']
  ip_address = node['postgresql']['master_address']
  replication_address = node['postgresql']['slave_address']
  archive_path = "/var/lib/postgresql/#{node['postgresql']['version']}/archive"

  execute 'Creating Archive Path' do
    command "mkdir -p #{archive_path} && chmod 700 -R #{archive_path} && chown -R postgres:postgres #{archive_path}"
  end

  directory '/var/lib/postgresql/.ssh' do
    owner 'postgres'
    group 'postgres'
    mode '0755'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/config' do
    source 'postgresql/config'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/id_rsa' do
    source 'postgresql/id_rsa'
    owner 'postgres'
    group 'postgres'
    mode '0400'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/id_rsa.pub' do
    source 'postgresql/id_rsa.pub'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/authorized_keys' do
    source 'postgresql/authorized_keys'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
  end
end

if node['postgresql']['is_slave']
  ip_address = node['postgresql']['slave_address']
  replication_address = node['postgresql']['master_address']
  data_path = "/var/lib/postgresql/#{node['postgresql']['version']}/data"

  execute 'Creating Archive Path' do
    command "mkdir -p #{data_path} && chmod 700  -R #{data_path} && chown -R postgres:postgres #{data_path}"
  end

  template "#{data_path}/recovery.conf" do
    source 'postgresql/recovery.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
  end

  directory '/var/lib/postgresql/.ssh' do
    owner 'postgres'
    group 'postgres'
    mode '0744'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/config' do
    source 'postgresql/config'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/id_rsa.pub' do
    source 'postgresql/id_rsa.pub'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
  end

  cookbook_file '/var/lib/postgresql/.ssh/authorized_keys' do
    source 'postgresql/authorized_keys'
    owner 'postgres'
    group 'postgres'
    mode '0664'
    action :create
  end
end

if node['postgresql']['replication']
  template "/etc/postgresql/#{node['postgresql']['version']}/main/postgresql.conf" do
    source 'postgresql/postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(
        listen_addresses: ip_address
    )
  end

  template "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf" do
    source 'postgresql/pg_hba.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(
        listen_addresses: ip_address,
        replication_address: replication_address
    )
  end
end

service 'postgresql' do
  action :restart
end

execute 'test' do
  user 'postgres'
  command "sudo su postgres && psql -c \"pg_start_backup('initial_backup');"
end

# psql -c "select pg_start_backup('initial_backup');"
# rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/9.6/main/ 192.168.1.112:/var/lib/postgresql/9.6/main/
# rsync -avz -e "ssh" --progress /var/lib/postgresql/9.6/main/ 192.168.1.112:/var/lib/postgresql/9.6/main/
# psql -c "select pg_stop_backup();"