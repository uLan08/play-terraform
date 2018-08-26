provider "aws" {
  region     = "${var.region}"
}

resource "aws_vpc" "terraform" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "terraform" {
  vpc_id = "${aws_vpc.terraform.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.terraform.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.terraform.id}"
}

resource "aws_subnet" "terraform" {
  vpc_id                  = "${aws_vpc.terraform.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "terraform" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.terraform.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "patrick" {
  key_name   = "patrick-ssh"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.patrick.key_name}"
  security_groups = ["${aws_security_group.terraform.id}"]
  subnet_id     = "${aws_subnet.terraform.id}"
}
