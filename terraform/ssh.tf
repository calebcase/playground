# Setup the users key pair.
resource "aws_key_pair" "user" {
  key_name   = "${var.uuid}-${var.env}-${var.ssh_key_pair}"
  public_key = "${var.ssh_key}"
}
