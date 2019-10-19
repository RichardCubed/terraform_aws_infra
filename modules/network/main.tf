# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count = "${var.az_count}"
  cidr_block = "${cidrsubnet(var.vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id = "${var.vpc.id}"
  tags = {
    Name = "${var.env}-private-${count.index}"
  }
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count = "${var.az_count}"
  cidr_block  = "${cidrsubnet(var.vpc.cidr_block, 8, var.az_count + count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id = "${var.vpc.id}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index}"
  }
}

# IGW for the public subnet
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${var.vpc.id}"
  tags = {
    Name = "${var.env}-gateway"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id = "${var.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "nat_gateway" {
  count = "${var.az_count}"
  vpc = true
  depends_on = ["aws_internet_gateway.gateway"]
  tags = {
    Name = "${var.env}-gateway"
  }
}

resource "aws_nat_gateway" "gw" {
  count = "${var.az_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
  tags = {
    Name = "${var.env}-gw"
  }
}

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count = "${var.az_count}"
  vpc_id = "${var.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }
  tags = {
    Name = "${var.env}-private"
  }
}

# Explicitly associate the newly created route tables to the private subnets 
# (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count = "${var.az_count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# The primary public security group
resource "aws_security_group" "security_group" {
  name = "${var.env}-main"
  description = "Public access to the VPC"
  vpc_id = "${var.vpc.id}"
  # HTTP
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound on all ports to all destinations
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-main"
  }
} 