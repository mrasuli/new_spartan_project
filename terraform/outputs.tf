#we use output to communicate between the modules
#output is useful when you want to use multiple modules, if you want specfic ips, you have to create individual outputs
output "webserver_ip_addresses_output"{
  value = aws_instance.devops106_terraform_mrasuli_webserver_tf[*].public_ip #by adding the [*] terraform will know to add all the public ip of the resources
}
