output "security_group" {
  value = "${aws_security_group.security_group}"
}

output "server" {
  value = "${aws_instance.server}"
}
