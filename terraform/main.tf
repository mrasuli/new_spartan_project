provider "aws" {
  region = var.region_var

}
#resource takes 2 parameters, first one is the type of the resource and second is the name of the resource in terraform

resource "aws_vpc" "devops106_terraform_mrasuli_vpc_tf" {
  cidr_block = "10.208.0.0/16"
  enable_dns_support = true #vpc will not support the dns unless it gets these two as true
  enable_dns_hostnames = true
  tags = {
    Name = "devops106_terraform_mrasuli_vpc"
  }
}

resource "aws_subnet" "devops106_terraform_mrasuli_subnet_webserver_tf" {
  vpc_id = local.vpc_id_var
  cidr_block = "10.208.1.0/24"

  tags = {
    Name = "devops106_terraform_mrasuli_subnet_webserver"
  }
}

resource "aws_internet_gateway" "devops106_terraform_mrasuli_igw_tf" {
  vpc_id = local.vpc_id_var

  tags = {
    Name = "devops106_terraform_mrasuli_igw"
  }
}

resource "aws_route_table" "devops106_terraform_mrasuli_rt_public_tf" {
  vpc_id = local.vpc_id_var

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops106_terraform_mrasuli_igw_tf.id
  }

  tags = {
    Name = "devops106_terraform_mrasuli_rt_public"
  }
}

resource "aws_route_table_association" "devops106_terraform_mrasuli_rt_assoc_public_webserver_tf" {
  subnet_id = aws_subnet.devops106_terraform_mrasuli_subnet_webserver_tf.id
  route_table_id = aws_route_table.devops106_terraform_mrasuli_rt_public_tf.id
}

resource "aws_network_acl" "devops106_terraform_mrasuli_nacl_public_tf" {
  vpc_id = local.vpc_id_var

  ingress {
    rule_no    = 100
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  ingress {
    rule_no    = 200
    from_port  = 8080
    to_port    = 8080
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  ingress {
    rule_no    = 300
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  egress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"

  }

  egress {
    rule_no    = 200
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  egress {
    rule_no    = 10000
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }


  subnet_ids = [aws_subnet.devops106_terraform_mrasuli_subnet_webserver_tf.id]

  tags = {
    Name = "devops106_terraform_mrasuli_nacl_public"
  }
}

resource "aws_security_group" "devops106_terraform_mrasuli_sg_webserver_tf" {
  name = "devops106_terraform_mrasuli_sg_webserver"
  vpc_id = local.vpc_id_var

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = -1 # all the protocols are accepted
    to_port   = 0 # all ports are allowed
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops106_terraform_mrasuli_sg_webserver"
  }

}


data  "template_file" "app_init"{  #added this to get rid of the provessioners for the webserver
  template = file("../init-scripts/docker-install.sh")
}

resource "aws_instance" "devops106_terraform_mrasuli_webserver_tf" {
  ami = var.ubuntu_20_04_ami_id_variable
  instance_type = "t2.micro"
  key_name = var.public_key_name_var
  vpc_security_group_ids = [aws_security_group.devops106_terraform_mrasuli_sg_webserver_tf.id]

  subnet_id = aws_subnet.devops106_terraform_mrasuli_subnet_webserver_tf.id

  associate_public_ip_address = true

count = 3 # if we need more than 1 server, we put count here and add the number of servers

#### comment this out when working with ansible ####
user_data = data.template_file.app_init.rendered ### this is # for the ansible to config webservers### we pass the file data to initialise the machine, line 149

  tags = {
    Name = "devops106_terraform_mrasuli_webserver_${count.index}" #count will become an object, so this will create numbers the servers as 0,1,2 (as per instructions 3 or 4 on line 157)
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip  #the ip address of this instance. But since we dont have it we call it through self
    private_key =  file(var.private_key_file_path_var)  # here you pass on the information about where your private key os secondary_private_ip_address_count
  }
}

  ###the provisioner will tell terraform that the commands should be carried out remotely
  ### provisioning means setting up and running the images created
  ### YOU CAN REPLACE THE DOCKER INSTALLATION WITH db

# provisioner "file" {
#   source = "../init-scripts/docker-install.sh"
#   destination = "/home/ubuntu/docker-install.sh"
#
# }
#
#
#   provisioner "remote-exec" {
#     inline = [
#     "bash /home/ubuntu/docker-install.sh" # here instead of the whole code, we put the codes on another folder and call it here
#   ]
# }
    ###### we comment out the previous provsioners and add data instead ####

###add the path for the mongodb file
# provisioner "local-exec" {
#   command = "echo mongodb://${aws_instance.devops106_terraform_mrasuli_mongodb_tf.public_ip}:27017 >../database.config"
#
# }

# provisioner "remote-exec" {
#   inline = [
#     "docker run -d hello-world" #whenever you run the container, you got to run -d otherwise the server wont finish,
#     ]
#   }
#
# }


###############db

data  "template_file" "db_app_init"{  #added this to get rid of the provessioners for the webserver
  template = file("../init-scripts/mongodb-install.sh")
}

resource "aws_instance" "devops106_terraform_mrasuli_db_tf" {
  ami = var.ubuntu_20_04_ami_id_variable
  instance_type = "t2.micro"
  key_name = var.public_key_name_var
  vpc_security_group_ids = [aws_security_group.devops106_terraform_mrasuli_sg_db_tf.id]

  subnet_id = aws_subnet.devops106_terraform_mrasuli_subnet_db_tf.id

  associate_public_ip_address = true

  user_data = data.template_file.db_app_init.rendered #

  tags = {
    Name = "devops106_terraform_mrasuli_db"
  }


  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip  #the ip address of this instance. But since we dont have it we call it through self
    private_key =  file(var.private_key_file_path_var)  # here you pass on the information about where your private key os secondary_private_ip_address_count
  }
}




  # provisioner "file" {
  #   source = "../init-scripts/mongodb-install.sh"
  #   destination = "/home/ubuntu/mongodb-install.sh"
  # }
  #
  #
  # provisioner "remote-exec"  {
  #   inline = [
  #     "bash /home/ubuntu/mongodb-install.sh"
  #   ]
  # }


#   provisioner "remote-exec" {
#
#     inline = [
#       "sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf" #(mongo sed -i "here you will put the string or whatever") this command will replace a string with a new one on the config file, this is the automated way rather than (cat /etc/mongod.config)
#     ]
#   }
# }

resource "aws_route53_zone" "devops106_terraform_mrasuli_dns_zone_tf" {
  name = "mrasuli.devops106"

#with vpc here means its public, if you dont then it becomes private
  vpc {
    vpc_id = local.vpc_id_var
  }
}

#creating record automatically
resource "aws_route53_record" "devops106_terraform_mrasuli_dns_db_tf" {
  zone_id = aws_route53_zone.devops106_terraform_mrasuli_dns_zone_tf.zone_id
  name = "db"
  type = "A"
  ttl = "30"
  records = [aws_instance.devops106_terraform_mrasuli_db_tf.public_ip]

}


resource "aws_security_group" "devops106_terraform_mrasuli_sg_db_tf" {
  name = "devops106_terraform_mrasuli_sg_db"
  vpc_id = local.vpc_id_var

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = -1 # all the protocols are accepted
    to_port   = 0 # all ports are allowed
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops106_terraform_mrasuli_sg_db"
  }

}
resource "aws_subnet" "devops106_terraform_mrasuli_subnet_db_tf" {
  vpc_id = local.vpc_id_var
  cidr_block = "10.208.2.0/24"

  tags = {
    Name = "devops106_terraform_mrasuli_subnet_db"
  }
}


resource "aws_route_table_association" "devops106_terraform_mrasuli_rt_assoc_public_db_tf" {
  subnet_id = aws_subnet.devops106_terraform_mrasuli_subnet_db_tf.id
  route_table_id = aws_route_table.devops106_terraform_mrasuli_rt_public_tf.id
}

resource "aws_network_acl" "devops106_terraform_mrasuli_nacl_db_public_tf" {
  vpc_id = local.vpc_id_var

  ingress {
    rule_no    = 100
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  ingress {
    rule_no    = 200
    from_port  = 27017
    to_port    = 27017
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  ingress {
    rule_no    = 300
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  egress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"

  }

  egress {
    rule_no    = 200
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }

  egress {
    rule_no    = 10000
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }


  subnet_ids = [aws_subnet.devops106_terraform_mrasuli_subnet_db_tf.id]

  tags = {
    Name = "devops106_terraform_mrasuli_nacl_db_public"
  }
}
