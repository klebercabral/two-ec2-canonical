variable "default_ingress" {
  type = map(object({ description = string, cidr_blocks = list(string) }))
  default = {
    22   = { description = "Inbound para SSH", cidr_blocks = ["127.0.0.1/32"] }
    80   = { description = "Inbound para HTTP", cidr_blocks = ["127.0.0.1/32"] }
    443  = { description = "Inbound para HTTPS", cidr_blocks = ["127.0.0.1/32"] }
    5432 = { description = "Inbound para postgres", cidr_blocks = ["127.0.0.1/32"] }
  }
}
variable "region" { default = "us-east-1" }
variable "vpc_azs" { default = ["us-east-1a"] }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "vpc_public_subnets" { default = ["10.0.101.0/24"] }
variable "ec2_instance_type" { default = "t2.micro" }
variable "labname" { default = "my-cluster" }
variable "lab_tag" {
  type = map(string)
  default = {
    env = "prod"
  }
}