{
  "variables": {
    "destination_regions": "<AWS_DEFAULT_REGION>",
    "aws_vpc_id": "<AWS_VPC_ID>",
    "aws_subnet_id": "<AWS_SUBNET_ID>",
    "aws_ssh_username": "admin",
    "ami_name": "<AWS_LABEL>",
    "aws_access_key": "<AWS_ACCESS_KEY_ID>",
    "aws_secret_key": "<AWS_SECRET_ACCESS_KEY>"
  },

  "builders": [
    {
      "type": "amazon-ebs",
      "access_key": "{{user `aws_access_key`}}",
      "secret_key": "{{user `aws_secret_key`}}",
      "region": "{{user `destination_regions`}}",
      "ami_regions": "{{user `destination_regions`}}",
      "source_ami": "ami-003f19e0e687de1cd",
      "instance_type": "t2.nano",
      "vpc_id": "{{user `aws_vpc_id`}}",
      "subnet_id": "{{user `aws_subnet_id`}}",
      "ssh_username": "{{user `aws_ssh_username`}}",
      "ami_name": "{{user `ami_name`}}",
      "tags": {
        "Name": "{{user `ami_name`}}",
        "OS_Version": "ubuntu"
      }
    }
  ],

  "provisioners": [
      {
        "type": "file",
        "source": "packer/configure.sh",
        "destination": "/tmp/configure.sh"
      },
      {
        "type": "file",
        "source": "packer/authorized_keys",
        "destination": "/tmp/authorized_keys"
      },
      {
        "type": "shell",
        "inline": [
          "cd /tmp/ && ./configure.sh"
        ]
      }
  ]
}
