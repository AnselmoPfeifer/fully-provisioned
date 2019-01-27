output "instances" {
  value = {
    app-server = [
      "${aws_instance.app-server.tags.Name}",
      "${aws_instance.app-server.public_dns}",
      "${aws_instance.app-server.private_ip}",
      ["22", "80"]
    ]

    database-master = [
      "${aws_instance.data-base-master.tags.Name}",
      "${aws_instance.data-base-master.public_dns}",
      "${aws_instance.data-base-master.private_ip}",
      ["22", "5432"]
    ]

    database-slave = [
      "${aws_instance.data-base-slave.tags.Name}",
      "${aws_instance.data-base-slave.public_dns}",
      "${aws_instance.data-base-slave.private_ip}",
      ["22", "5432"]
    ]
  }
}
