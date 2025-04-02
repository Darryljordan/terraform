data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["km-devops-session-1-2025-2"]
  }
}

data "aws_internet_gateway" "existing_ig" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
}

data "aws_eip" "existing_eip" {
  public_ip = "54.78.238.172"
}

<<<<<<< Updated upstream
=======
data "aws_nat_gateway" "existing_nat_gateway" {
  filter {
    name   = "tag:Name"
    values = ["LB-nat-_terraform.tp_aws"]
  }
}

>>>>>>> Stashed changes
resource "aws_subnet" "km-kn-public-subnet-terra-tp-aws" {
  vpc_id                  = data.aws_vpc.existing_vpc.id
  cidr_block              = "50.20.10.32/28"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.prefix}-public-subnet-${var.suffix}"
  }
}

resource "aws_subnet" "km-kn-private-subnet-terra-tp-aws" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "50.20.0.16/28"
  availability_zone = "eu-west-1b"

  tags = {
    "Name" = "${var.prefix}-private-subnet-${var.suffix}"
  }
}

resource "aws_route_table" "km-kn-public-route-table-terra-tp-aws" {
  vpc_id = data.aws_vpc.existing_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_ig.id
  }
  tags = {
    "Name" = "${var.prefix}-public-route-table-${var.suffix}"
  }

  depends_on = [data.aws_internet_gateway.existing_ig]
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.km-kn-public-subnet-terra-tp-aws.id
  route_table_id = aws_route_table.km-kn-public-route-table-terra-tp-aws.id
}

resource "aws_nat_gateway" "km-kn-NAT-gateway-terra-tp-aws" {
  allocation_id     = data.aws_eip.existing_eip.id
  subnet_id         = aws_subnet.km-kn-public-subnet-terra-tp-aws.id
  connectivity_type = "public"
  depends_on        = [data.aws_internet_gateway.existing_ig]
  tags = {
    "Name" = "${var.prefix}-NAT-gateway-${var.suffix}"
  }
}

resource "aws_route_table" "km-kn-private-route-table-terra-tp-aws" {
  vpc_id = data.aws_vpc.existing_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.km-kn-NAT-gateway-terra-tp-aws.id
  }
  tags = {
    "Name" = "${var.prefix}-private-route-table-${var.suffix}"
  }
  depends_on = [aws_nat_gateway.km-kn-NAT-gateway-terra-tp-aws]
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.km-kn-private-subnet-terra-tp-aws.id
  route_table_id = aws_route_table.km-kn-private-route-table-terra-tp-aws.id
}