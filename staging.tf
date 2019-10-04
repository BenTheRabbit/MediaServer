provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

provider "ovh" {
	application_key = "${var.ovh_application_key}"
	application_secret = "${var.ovh_application_secret}"
	consumer_key = "${var.ovh_consumer_key}"
	endpoint = "ovh-eu"
}


resource "random_string" "server_name" {
	length = 10
	upper = false
	number = false
	special = false
}

resource "aws_security_group" "${random_string.server_name.result}_administration" {
	name = "administration"
	description = "Allow remote connexion for administration of the server"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "${random_string.server_name.result}_plex" {
	name = "plex"
	description = "Allow traffic for Plex Media Server"

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "${random_string.server_name.result}_to_all" {
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
	ami = "${lookup(var.aws_amis, var.aws_region)}"
	instance_type = "t2.micro"

	security_groups = ["${aws_security_group.${random_string.server_name.result}_administration.name}", "${aws_security_group.${random_string.server_name.result}_plex.name}", "${aws_security_group.${random_string.server_name.result}_to_all.name}"]
	tags = {
		Name = "${random_string.server_name.result}.gandalfstyle.com"

	}

	user_data = <<-EOF
#!/bin/bash
while [ ! -f /usr/bin/python ]; do
	pacman -Sy python --noconfirm
done
pacman -Suy --noconfirm
echo "${random_string.server_name.result}.gandalfstyle.com" > /etc/hostname
hostname "${random_string.server_name.result}.gandalfstyle.com"
EOF


}



resource "ovh_domain_zone_record" "a_sub" {
	zone = "gandalfstyle.com"
	subdomain = random_string.server_name.result
	fieldtype = "A"
	ttl = "3600"
	target = aws_instance.media_server.public_ip
}

resource "ovh_domain_zone_record" "wildcard_sub" {
	zone = "gandalfstyle.com"
	subdomain = "*.${random_string.server_name.result}"
	fieldtype = "A"
	ttl = "3600"
	target = aws_instance.media_server.public_ip
}
