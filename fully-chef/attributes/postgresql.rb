default['postgresql']['version']                = '9.6'
default['postgresql']['apt_repository']         = 'apt.postgresql.org'
default['postgresql']['apt_distribution']       = node['lsb']['codename']
default['postgresql']['libs']                   = ['libpq5', 'libpq-dev']
default['postgresql']['data_directory']         = '/data/postgresql/'
default['postgresql']['apt_components']         = ['main', node['postgresql']['version']]
default['postgresql']['initdb_options']         = '--locale=en_US.UTF-8'
default['postgresql']['listen_addresses']       = '*'
default['postgresql']['pg_hba']                 = []
default['postgresql']['apt_uri']                = 'http://apt.postgresql.org/pub/repos/apt'
default['postgresql']['apt_key']                = 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
default['postgresql']['listen_addresses']       = 'localhost'

default['postgresql']['default_username']       = 'postgres'
default['postgresql']['default_password']       = 'password'
default['postgresql']['replication_username']   = 'replication'
default['postgresql']['replication_password']   = 'password'

default['postgresql']['replication']            = false
default['postgresql']['master_address']         = nil
default['postgresql']['slave_address']          = nil
default['postgresql']['is_master']              = false
default['postgresql']['is_slave']               = false