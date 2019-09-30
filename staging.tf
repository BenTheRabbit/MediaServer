provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

resource "aws_security_group" "administration" {
	name = "administration"
	description = "Allow remote connexion for administration of the server"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "plex" {
	name = "plex"
	description = "Allow traffic for Plex Media Server"

	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "to_all" {
	name = "to_all"
	description = "Allow to internet, all port"

	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "media_server" {
	key_name = "${var.aws_key_name}"
	am = "${lookup(var.aws_amis, var.aws_region)}"
	instance_type = "t2.micro"

	security_groups = ["${aws_security_group.administration.name}", "${aws_security_group.plex.name}", "${aws_security_group.to_all.name}"]
}
