default['postgresql']['version']          = '9.6'
default['postgresql']['apt_repository']   = 'apt.postgresql.org'
default['postgresql']['apt_distribution'] = node['lsb']['codename']
default['postgresql']['libs']             = ['libpq5', 'libpq-dev']
default['postgresql']['apt_components']   = ['main', node['postgresql']['version']]
default['postgresql']['apt_uri']          = 'http://apt.postgresql.org/pub/repos/apt'
default['postgresql']['apt_key']          = 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
