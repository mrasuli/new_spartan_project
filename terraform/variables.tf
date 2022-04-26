variable "private_key_file_path_var" {  #this will be the name of the v
  default = "/home/vagrant/.ssh/devops106_mrasuli.pem" #
}

variable "ubuntu_20_04_ami_id_variable" {
  default =  "ami-08ca3fed11864d6bb"
}

variable "public_key_name_var" {
  default = "devops106_mrasuli"
}

variable "region_var" {
  default = "eu-west-1"
}


locals {
  vpc_id_var = aws_vpc.devops106_terraform_mrasuli_vpc_tf.id
}
