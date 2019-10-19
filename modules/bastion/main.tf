resource "aws_instance" "instance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = "true"
  subnet_id = "${var.subnet_ids[0]}"
  security_groups = ["${var.security_group.id}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.env}-bastion"
  }
}