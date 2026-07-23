output "master_ip" {

  value = aws_instance.master.public_ip

}

output "replica_ip" {

  value = aws_instance.replica.public_ip

}
