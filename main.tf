resource "aws_vpc" "myvpc" {
cidr_block = var.cidr
tags = {
   Name = "myvpc"
}
}

resource "aws_subnet" "sub1" {
 vpc_id = aws_vpc.myvpc.id
 cidr_block = "10.0.0.0/24"
 map_public_ip_on_launch = "true"
 availability_zone = "ap-southeast-2a"
tags = {
  Name = "mysub1"
}
}

resource "aws_subnet" "sub2" {
vpc_id = aws_vpc.myvpc.id
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = "true"
availability_zone = "ap-southeast-2b"
tags = {
  Name = "mysub2"
}
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.myvpc.id 
 tags = {
     Name = "myigw"
   }
}

resource "aws_route_table" "rt" {
 vpc_id = aws_vpc.myvpc.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
     tags = {
        Name = "myrt"
         }
}

resource "aws_route_table_association" "suba1" {
 subnet_id = aws_subnet.sub1.id
 route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "suba2" {
subnet_id = aws_subnet.sub2.id
route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "mysg" {
  name        = "websg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "dharmbuckettestpoc"

  tags = {
    Name        = "aws-tf-s3-bucket-poc-test1996"
    Environment = "Dev"
  }
}

resource "aws_instance" "webserver1" {
  ami           = "ami-080660c9757080771"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("userdata.sh"))

  tags = {
    Name = "ins1"
  }
}

resource "aws_instance" "webserver2" {
  ami           = "ami-080660c9757080771"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("userdata1.sh"))

  tags = {
    Name = "ins2"
  }
}
