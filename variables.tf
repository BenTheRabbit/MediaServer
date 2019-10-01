variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_name" {}
variable "aws_key_path" {}

variable "aws_region" {
	default = "eu-west-2"
}

variable "aws_amis" {
	default = {
		eu-central-1 = "ami-0d55d442d7643e432"
		eu-west-1 = "ami-0bf1a6722e14b4bb5"
		eu-west-2 = "ami-0343baa2448667d18"
	}
}


variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}


