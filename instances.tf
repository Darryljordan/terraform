data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "km-kn-EC2-public-terra-tp-aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.km-kn-public-subnet-terra-tp-aws.id

  user_data = <<-EOF
            sudo dnf clean packages
            sudo dnf clean all
            sudo rpm --import https://rpm.nodesource.com/pubkey.gpg
            
            sudo dnf install -y https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm
            sudo dnf install -y nodejs      
  EOF
  security_groups = [ aws_security_group.km-kn-security-group-terra-tp-aws.id ]
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
  ami           = data.aws_ami.ubuntu.id
  user_data     = <<-EOF
            sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
            sudo dnf install -y mysql-community-server mysql-community-client
            sudo systemctl start mysqld
            sudo systemctl enable mysqld
            sudo systemctl status mysqld
  EOF
    security_groups = [ aws_security_group.km-kn-security-group-terra-tp-aws.id ]
  tags = {
    "Name" = "${var.prefix}-EC2-private-${var.suffix}"
  }
}

resource "aws_ec2_instance_state" "km-kn-private-ec2-state-tp-aws" {
  instance_id = aws_instance.km-kn-EC2-private-terra-tp-aws.id
  state       = "running"
}

resource "aws_security_group" "km-kn-security-group-terra-tp-aws" {
    vpc_id = data.aws_vpc.existing_vpc.id
    name = "EC2 security groups"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}