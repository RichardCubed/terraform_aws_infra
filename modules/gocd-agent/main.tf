# The final step in configuring our GOCD agent requires us to run a number of shell
# commmands to point it at our GOCD server.  We'll use a Terraform template for this.
data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"
  vars = {
    region = "${var.region}"
    ssh_key_path = "/infra/gocd/github/id_rsa"
    gocd_server_ip = "${var.gocd_server.private_ip}"
  }
}

# We're ready to launch our instance.  Our GOCD agents are based on an AMI we created
# previously with Packer.
resource "aws_instance" "agent" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.profile.name}"
  associate_public_ip_address = "false"
  subnet_id = "${var.subnet_ids[0]}"
  security_groups = ["${var.security_group.id}", "${var.gocd_security_group.id}"]
  key_name = "${var.key_name}"
  user_data = "${data.template_file.user_data.rendered}"
  tags = {
    Name = "${var.env}-gocd-agent"
  }
}