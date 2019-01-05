#
# Cookbook:: fully-chef
# Recipe:: default
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

include_recipe 'apt'
include_recipe 'hostnames'
include_recipe 'sysctl::apply'

apt_update 'update'

package 'net-tools' do
  action :install
end

include_recipe 'fully-chef::_hardening'
include_recipe 'fully-chef::_timezone'
