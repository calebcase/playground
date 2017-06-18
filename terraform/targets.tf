################################################################################
# Setup network space for the targets to run in.

# Target machines will be lauched into this VPC.
resource "aws_vpc" "targets" {
  cidr_block                       = "10.4.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true

  tags = {
    Name = "targets"
  }
}

# Subnet for our target machines.
resource "aws_subnet" "targets" {
  vpc_id     = "${aws_vpc.targets.id}"
  cidr_block = "10.4.200.0/24"

  tags = {
    Name = "targets"
  }
}

# We will need an internet gateway for the targets to access the rest of the
# world.
resource "aws_internet_gateway" "targets" {
  vpc_id = "${aws_vpc.targets.id}"

  depends_on = [
    "aws_subnet.targets",
  ]
}

# Targets need a route to get out.
resource "aws_route" "targets-internet" {
  route_table_id         = "${aws_vpc.targets.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.targets.id}"

  depends_on = [
    "aws_internet_gateway.targets",
  ]
}

# Targets security group.
resource "aws_security_group" "targets" {
  name   = "targets"
  vpc_id = "${aws_vpc.targets.id}"

  # SSH in from the internet and itself.
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]

    self = true
  }

  # Outbound internet access.
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

################################################################################
# Target machines themselves.

resource "aws_instance" "ubuntu-server-16-04" {
  instance_type = "t2.micro"
  ami           = "ami-7b2e086d"

  key_name = "ccase"

  vpc_security_group_ids = [
    "${aws_security_group.targets.id}",
  ]

  subnet_id = "${aws_subnet.targets.id}"

  tags = {
    Name = "targets"
  }
}
