resource "aws_instance" "km-kn-EC2-public-terra-tp-aws" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.km-kn-public-subnet-terra-tp-aws.id

  user_data = <<-EOF
            #!/bin/bash
            sudo dnt -y update
            sudo dnf install -y nodejs  

            # Install N and upgrade Node.js
            sudo npm cache clean -f
            sudo npm install -g n
            sudo n stable

            sudo npm install -g @angular/cli
            ng version  # Check Angular installation
            echo "Node.js and Angular CLI installed successfully."                   
  EOF
<<<<<<< Updated upstream
  security_groups = [ aws_security_group.km-kn-security-group-terra-tp-aws.id ]
  key_name = aws_key_pair.km-kn-public-key-terra-tp-aws.key_name
=======
  vpc_security_group_ids = [ aws_security_group.km-kn-public-security-group-terra-tp-aws.id ]
  key_name = aws_key_pair.km-kn-key-terra-tp-aws.key_name
>>>>>>> Stashed changes
  tags = {
    "Name" = "${var.prefix}-EC2-public-${var.suffix}"
  }
}

resource "aws_ec2_instance_state" "km-kn-public-ec2-state-tp-aws" {
  instance_id = aws_instance.km-kn-EC2-public-terra-tp-aws.id
  state       = "running"
}

resource "aws_instance" "km-kn-EC2-private-terra-tp-aws" {
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.km-kn-private-subnet-terra-tp-aws.id
  ami           = var.ami
  user_data     = <<-EOF
            #!/bin/bash
            # Clean any previous package caches
            sudo dnf -y clean packages
            sudo dnf -y clean all

            sudo dnt -y update

            sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
            sudo dnf install -y mysql-community-server mysql-community-client
            sudo systemctl start mysqld
            sudo systemctl enable mysqld
            sudo systemctl status mysqld
  EOF
<<<<<<< Updated upstream
    security_groups = [ aws_security_group.km-kn-security-group-terra-tp-aws.id ]
    key_name = aws_key_pair.km-kn-private-key-terra-tp-aws.key_name
=======
    vpc_security_group_ids = [ aws_security_group.km-kn-private-security-group-terra-tp-aws.id ]
    key_name = aws_key_pair.km-kn-key-terra-tp-aws.key_name
>>>>>>> Stashed changes
  tags = {
    "Name" = "${var.prefix}-EC2-private-${var.suffix}"
  }
}

resource "aws_ec2_instance_state" "km-kn-private-ec2-state-tp-aws" {
  instance_id = aws_instance.km-kn-EC2-private-terra-tp-aws.id
  state       = "running"
}

resource "aws_security_group" "km-kn-public-security-group-terra-tp-aws" {
    vpc_id = data.aws_vpc.existing_vpc.id
    name = "Public-EC2-security-group"
}

resource "aws_vpc_security_group_ingress_rule" "public_ingress_tcp" {
  security_group_id = aws_security_group.km-kn-public-security-group-terra-tp-aws.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "public_ingress_https" {
  security_group_id = aws_security_group.km-kn-public-security-group-terra-tp-aws.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "public_egress" {
  security_group_id = aws_security_group.km-kn-public-security-group-terra-tp-aws.id
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_security_group" "km-kn-private-security-group-terra-tp-aws" {
    vpc_id = data.aws_vpc.existing_vpc.id
    name = "Private-EC2-security-group"
}

resource "aws_vpc_security_group_ingress_rule" "private_ingress_tcp" {
  security_group_id = aws_security_group.km-kn-private-security-group-terra-tp-aws.id
  cidr_ipv4   = "50.20.10.32/28"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "private_egress" {
  security_group_id = aws_security_group.km-kn-private-security-group-terra-tp-aws.id
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_key_pair" "km-kn-key-terra-tp-aws" {
  key_name = "km-kn-public-key-terra-tp-aws"
  public_key = file("~/.ssh/km-kn-key-public.pub")
  tags = {
    "Name" = "${var.prefix}-public-key-terra-${var.suffix}"
  }
}
