# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_access_key}"
}

# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Configure the network
module "network" {
  source = "../modules/network"
  env = "${var.env}"
  vpc = "${aws_vpc.vpc}"
  az_count = "${var.az_count}"
}

# Bastion host
# https://aws.amazon.com/blogs/security/tag/bastion-host/
module "bastion" {
  source = "../modules/bastion"
  aws_account_number = "${var.aws_account_number}"
  region = "${var.region}"
  env = "${var.env}"
  vpc_id = "${aws_vpc.vpc.id}"
  ami = "ami-035b3c7efe6d061d5"
  instance_type = "t3.micro"
  key_name = "${var.key_name}"
  subnet_ids = "${module.network.subnet_public_ids}"
  security_group = "${module.network.security_group}"
}

# GOCD Server
# https://docs.gocd.org/current/installation/installing_go_server.html
module "gocd-server" {
  source = "../modules/gocd-server"
  aws_account_number = "${var.aws_account_number}"
  region = "${var.region}"
  env = "${var.env}"
  vpc_id = "${aws_vpc.vpc.id}"
  ami = "ami-070a729aedc8194f0"
  instance_type = "t3.small"
  key_name = "${var.key_name}"
  subnet_ids = "${module.network.subnet_private_ids}"
  security_group = "${module.network.security_group}"
}

# GOCD Agent
# https://docs.gocd.org/current/installation/installing_go_agent.html
module "gocd-agent" {
  source = "../modules/gocd-agent"
  aws_account_number = "${var.aws_account_number}"
  region = "${var.region}"
  env = "${var.env}"
  ami = "ami-0862b40e1863067f5"
  instance_type = "t3.small"
  key_name = "${var.key_name}"
  subnet_ids = "${module.network.subnet_private_ids}"
  security_group = "${module.network.security_group}"
  gocd_security_group = "${module.gocd-server.security_group}"
  gocd_server = "${module.gocd-server.server}"
}