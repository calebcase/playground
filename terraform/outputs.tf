output "bastion-ubuntu-server-ip" {
  value = "${aws_instance.bastions-ubuntu-server-16-04.public_ip}"
}

output "bastion-kali-ip" {
  value = "${aws_instance.bastions-kali.public_ip}"
}

output "target-ubuntu-16.04" {
  value = "${aws_instance.targets-ubuntu-server-16-04.private_ip}"
}
