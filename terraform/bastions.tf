################################################################################
# Setup network space for the bastions to run in.

# Bastions machines will be lauched into this VPC.
resource "aws_vpc" "bastions" {
  cidr_block                       = "10.6.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true

  tags = {
    Name = "${var.uuid}-${var.env}-bastions"
  }
}

# Subnet for our bastion machines.
resource "aws_subnet" "bastions" {
  vpc_id     = "${aws_vpc.bastions.id}"
  cidr_block = "10.6.0.0/24"

  tags = {
    Name = "${var.uuid}-${var.env}-bastions"
  }
}

# We will need an internet gateway for the bastions to access the rest of the
# world.
resource "aws_internet_gateway" "bastions" {
  vpc_id = "${aws_vpc.bastions.id}"

  depends_on = [
    "aws_subnet.bastions",
  ]
}

# Bastions need a route to get out.
resource "aws_route" "bastions-internet" {
  route_table_id         = "${aws_vpc.bastions.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.bastions.id}"

  depends_on = [
    "aws_internet_gateway.bastions",
  ]
}

# Bastions security group.
resource "aws_security_group" "bastions" {
  name   = "${var.uuid}-${var.env}-bastions"
  vpc_id = "${aws_vpc.bastions.id}"

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

# Peer the bastion and target VPC so that we can access target machines.
resource "aws_vpc_peering_connection" "bastions-targets" {
  vpc_id      = "${aws_vpc.bastions.id}"
  peer_vpc_id = "${aws_vpc.targets.id}"

  auto_accept = true

  tags {
    Name = "${var.uuid}-${var.env}-bastions"
  }

  depends_on = [
    "aws_vpc.bastions",
    "aws_vpc.targets",
  ]
}

# Give the bastions a route to the targets.
resource "aws_route" "bastions-targets" {
  route_table_id            = "${aws_vpc.bastions.main_route_table_id}"
  destination_cidr_block    = "${aws_subnet.targets.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastions-targets.id}"

  depends_on = [
    "aws_vpc_peering_connection.bastions-targets",
  ]
}

# Give the targets a route to the bastions.
resource "aws_route" "targets-bastions" {
  route_table_id            = "${aws_vpc.targets.main_route_table_id}"
  destination_cidr_block    = "${aws_subnet.bastions.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastions-targets.id}"

  depends_on = [
    "aws_vpc_peering_connection.bastions-targets",
  ]
}

################################################################################
# Bastion machines themselves.

resource "aws_instance" "bastions-ubuntu-server-16-04" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu-server-16-04.id}"

  key_name = "${aws_key_pair.user.key_name}"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.bastions.id}",
  ]

  subnet_id = "${aws_subnet.bastions.id}"

  tags = {
    Name = "${var.uuid}-${var.env}-bastions"
  }
}

resource "aws_instance" "bastions-kali" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.kali.id}"

  key_name = "${aws_key_pair.user.key_name}"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.bastions.id}",
  ]

  subnet_id = "${aws_subnet.bastions.id}"

  tags = {
    Name = "${var.uuid}-${var.env}-bastions"
  }
}
