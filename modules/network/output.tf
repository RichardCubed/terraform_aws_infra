output "gateway" {
  value = "${aws_internet_gateway.gateway}"
}

output "subnet_public_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "subnet_private_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "security_group" {
  value = "${aws_security_group.security_group}"
}