name 'fully-chef'
maintainer 'Anselmo Pfeifer'
maintainer_email 'contatc@anselmopfeifer.com'
license 'All Rights Reserved'

description 'Installs/Configures fully-chef'
long_description 'Installs/Configures fully-chef'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

issues_url 'https://github.com/AnselmoPfeifer/fully-provisioned/issues'
source_url 'https://github.com/AnselmoPfeifer/fully-provisioned/issues'

depends 'sshd',     '= 1.3.0'
depends 'sysctl',   '= 0.7.0'
depends 'hostname', '= 0.4.2'
depends 'apt',      '= 7.0.0'

recipe 'fully-chef::_hardening',  'Is the Internal recipe to apply the hardening options'
recipe 'fully-chef::_timezone',   'Is the Internal recipe to configure timezone'
recipe 'fully-chef::default',     'Recipe to install and configure linux environment'
recipe 'fully-chef::nginx',       'Is the Web Server to host the PHP Application'
recipe 'fully-chef::deployment',  'Is the External recipe to execute the deploy on web server'
