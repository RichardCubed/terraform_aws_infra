# GOCD requires that port 8153 and 8154 be accessable between the server and it's agents.
# We'll create a new security group for this.  We'll include the agents in this group later
# to lock down traffic between the server and it's agents.
resource "aws_security_group" "security_group" {
  name = "${var.env}-gocd"
  description = "Allows traffic between the GOCD server and associated agents"
  vpc_id = "${var.vpc_id}"
  # HTTP
  ingress {
    protocol = "tcp"
    from_port = 8153
    to_port = 8153
    self = true
  }
  # HTTPS
  ingress {
    protocol = "tcp"
    from_port = 8154
    to_port = 8154
    self = true
  }
  # All all outbound traffic
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-gocd"
  }
}

# The final step in configuring our GOCD server requires us to run a number of shell
# commmands.  We'll use a Terraform template for this.
data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"
  vars = {
    region = "${var.region}"
    ssh_key_path = "/infra/gocd/github/id_rsa"
  }
}

# We're ready to launch our instance.  Our GOCD server is based on an AMI we created
# previously with Packer.
resource "aws_instance" "server" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.profile.name}"
  associate_public_ip_address = "false"
  subnet_id = "${var.subnet_ids[0]}"
  security_groups = ["${var.security_group.id}", "${aws_security_group.security_group.id}"]
  key_name = "${var.key_name}"
  user_data = "${data.template_file.user_data.rendered}"
  tags = {
    Name = "${var.env}-gocd-server"
  }
}