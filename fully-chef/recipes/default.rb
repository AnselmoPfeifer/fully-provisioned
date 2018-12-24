#
# Cookbook:: fully-chef
# Recipe:: default
#
# Copyright:: 2019, Anselmo Pfeifer, All Rights Reserved.

include_recipe 'apt'
include_recipe 'hostnames'
include_recipe 'sysctl::apply'

apt_update 'update'

node['fully-chef']['default_packages'].each do | pkg |
  apt_package pkg do
    action :install
  end
end

execute 'pip install --upgrade pip'

# *** /dev/xvda1 should be checked for errors ***
execute 'enabling auto-fsck fix to prevent boot hangup' do
  command <<-'EOH'
      sudo touch /forcefsck || true
      sudo sed -i 's/#FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS || true
  EOH
end

include_recipe 'fully-chef::_hardening'
include_recipe 'fully-chef::_timezone'
