variable "region" {

  description = "Região da AWS"

  default = "sa-east-1"

}

variable "availability_zone" {
  description = "Zona de disponibilidade"
  default     = "us-east-1a"
}

variable "instance_type" {

  default = "t3.micro"

}

variable "private_key_path" {

  description = "Caminho da chave privada"
}

variable "key_name" {

  description = "Nome da chave SSH"

}

variable "vpc_cidr" {

  default = "10.0.0.0/16"

}

variable "subnet_cidr" {

  default = "10.0.1.0/24"

}

variable "ami" {

  description = "AMI Ubuntu"

}
