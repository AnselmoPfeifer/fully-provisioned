resource "aws_iam_instance_profile" "profile" {
  name = "Instance-Profile-${var.label}"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_instance" "app-server" {
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  subnet_id = "${aws_subnet.subnet.*.id[count.index]}"
  instance_type = "t2.nano"
  ami = "${var.aws_ami}"
  associate_public_ip_address = true
  monitoring = false

  security_groups = [
    "${aws_security_group.internal_access.id}",
    "${aws_security_group.external_access.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "app-server"
  }
}

resource "aws_instance" "data-base-master" {
  iam_instance_profile= "${aws_iam_instance_profile.profile.id}"
  subnet_id = "${aws_subnet.subnet.*.id[count.index]}"
  instance_type = "t2.nano"
  ami = "${var.aws_ami}"
  associate_public_ip_address = true
  monitoring = false

  security_groups = [
    "${aws_security_group.internal_access.id}",
    "${aws_security_group.external_access.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "postgres-master"
  }
}

resource "aws_instance" "data-base-slave" {
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  subnet_id = "${aws_subnet.subnet.*.id[count.index]}"
  instance_type = "t2.nano"
  ami = "${var.aws_ami}"
  associate_public_ip_address = true
  monitoring = false

  security_groups = [
    "${aws_security_group.internal_access.id}",
    "${aws_security_group.external_access.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "postgres-slave"
  }
}
