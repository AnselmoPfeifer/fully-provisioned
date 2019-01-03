#
# Cookbook:: fully-chef
# Recipe:: default
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

apt_update 'update'

package 'net-tools' do
  action :install
end

include_recipe 'fully-chef::_hardening'
include_recipe 'fully-chef::_timezone'
