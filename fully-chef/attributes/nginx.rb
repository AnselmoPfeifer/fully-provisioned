default['nginx']['domains'] = []
default['nginx']['log_dir'] = '/var/log/nginx'
default['nginx']['ip_address'] = node['ipaddress']
default['nginx']['default_directory'] = "#{node['fully-chef']['directory']}/www"
