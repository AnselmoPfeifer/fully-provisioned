output "app-server" {
  value = {
    name = "${aws_instance.app-server.tags.Name}",
    public-dns = "${aws_instance.app-server.public_dns}",
    ports = [
      "22",
      "80"
    ]
  }
}

output "database-master" {
  value = {
    name = "${aws_instance.data-base-master.tags.Name}",
    public-dns = "${aws_instance.data-base-master.public_dns}",
    ports = [
      "22",
      "5432"
    ]
  }
}

output "database-slave" {
  value = {
    name = "${aws_instance.data-base-slave.tags.Name}",
    public-dns = "${aws_instance.data-base-slave.public_dns}",
    ports = [
      "22",
      "5432"
    ]
  }
}