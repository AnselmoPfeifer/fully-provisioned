resource "aws_security_group" "internal_access" {
  name = "sg_allow_internal_access"
  description = "Allow Internal access"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["10.0.0.0/16"]
    description = "Enable all internal access inbound"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
    description = "Enable all access outbound"
  }

  tags {
    Name = "allow internal access"
  }
}

resource "aws_security_group" "external_access" {
  name = "sg_allow_external_accesss"
  description = "Allow External access"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Enable all HTTP access inbound"
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Enable all HTTPs access inbound"
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "Enable SSH port on inbound"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description = "Enable all access outbound"
  }

  tags {
    Name = "allow external access"
  }
}
