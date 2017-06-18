data "aws_ami" "ubuntu-server-16-04" {
  owners = [
    "099720109477",
  ]

  most_recent = true

  filter {
    name = "name"

    values = [
      "*hvm-ssd*-16.04*",
    ]
  }
}
