resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_classiclink = true
  enable_dns_hostnames = true
  enable_classiclink_dns_support = true

  tags = {
    Name = "Vpc-${var.label}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "Gateway-${var.label}"
  }
}

resource "aws_subnet" "subnet" {
  count = 3
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags {
    Name = "Subnet-${var.label}-${count.index}"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
  tags {
    Name = "route-table-${var.label}"
  }
}

resource "aws_route_table_association" "route-table-association" {
  count = 3
  subnet_id = "${aws_subnet.subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.route-table.id}"
}
