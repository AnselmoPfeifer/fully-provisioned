#
# Cookbook:: fully-chef
# Recipe:: php-fpm
#
# Copyright:: 2019, Anselmo Pfeifer, All Rights Reserved.

apt_update 'update'

apt_package node['php-fpm']['package_name'] do
  action :install
end

directory node['php-fpm']['log_dir']

template '/etc/php/7.0/fpm/php.ini' do
  source 'php-fpm/php.ini.erb'
end

template '/etc/php/7.0/fpm/php-fpm.conf' do
  source 'php-fpm/php-fpm.conf.erb'
end

service node['php-fpm']['package_name'] do
  service_name node['php-fpm']['package_name']
  supports start: true, stop: true, restart: true, reload: true
  action [:enable, :start]
end

