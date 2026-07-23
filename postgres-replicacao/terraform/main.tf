resource "aws_vpc" "postgres" {

  cidr_block = var.vpc_cidr

  tags = {

    Name = "postgres-vpc"

  }

}
resource "aws_subnet" "public" {

  vpc_id = aws_vpc.postgres.id

  cidr_block = var.subnet_cidr
  
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

}
resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.postgres.id

}
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.postgres.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.gw.id

  }

}

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}
resource "aws_security_group" "postgres" {

  name = "postgres"

  vpc_id = aws_vpc.postgres.id

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port = 5432

    to_port = 5432

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}
locals {
  master_ip  = "10.0.1.10"
  replica_ip = "10.0.1.11"
}
resource "aws_instance" "master" {

  ami = var.ami

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id
  
  associate_public_ip_address = true

  private_ip = local.master_ip

  key_name = var.key_name

  vpc_security_group_ids = [

    aws_security_group.postgres.id

  ]

  user_data = file("user-data.sh")
  
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
  inline = [
    "mkdir -p /home/ubuntu/postgres/replicacao/master"
  ]
}
  provisioner "file" {
  source      = "../master/"
  destination = "/home/ubuntu/postgres/replicacao/master"
}
  provisioner "remote-exec" {
  inline = [
    "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done",
    "export REPLICA_IP=${local.replica_ip}",
    "chmod +x /home/ubuntu/postgres/replicacao/master/master.sh",
    "bash /home/ubuntu/postgres/replicacao/master/master.sh"
  ]
}
  tags = {

    Name = "postgres-master"

  }

}
resource "aws_instance" "replica" {

  ami = var.ami

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id
  
  associate_public_ip_address = true

  private_ip = local.replica_ip

  key_name = var.key_name

  vpc_security_group_ids = [

    aws_security_group.postgres.id

  ]

  user_data = file("user-data.sh")
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
  inline = [
    "mkdir -p /home/ubuntu/postgres/replicacao/replica"
  ]
}
  provisioner "file" {
    source      = "../replica/"
    destination = "/home/ubuntu/postgres/replicacao/replica/"
}
provisioner "remote-exec" {
  inline = [
    "export MASTER_IP=${local.master_ip}",
    "chmod +x /home/ubuntu/postgres/replicacao/replica/replica.sh",
    "bash /home/ubuntu/postgres/replicacao/replica/replica.sh"
  ]
}
  tags = {

    Name = "postgres-replica"

  }

}