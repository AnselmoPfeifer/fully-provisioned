# PACKER

## Build an immutable AWS AMI with Packer, based on json template
- variables: Custom variables that can be overriden during runtime by using the -var flag.
- builders: You can specify multiple builders depending on the target platforms (EC2, VMware, Google Cloud, Docker).
- provisioners: You can pass a shell script or use configuration managements tools like Ansible, Chef,
Puppet or Salt to provision the AMI and install all required packages and softwares.