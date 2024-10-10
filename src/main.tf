provider "aws" {
  region     = "us-east-1"  # N. Virginia region
  ##access_key = "AKIAZI2LFZ6QCS24PBFU"  # Use environment variables or secrets manager for real deployments
  ##secret_key = "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"  # Use environment variables or secrets manager for real deployments
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
}
/**
resource "<Provider>_<resource_types>" "name" {
  config options......
  key = "value"
  key2 = "another value"
}
**/

# Create an instance
/*resource "aws_instance" "my-first-ec2instance" { ## The name here is used with in our terraform
  ami = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  tags = { ## This name is created in aws
    Name = "amazon-linux"
  }
}*/

# 1. Create a vpc (Virtual Private Cloud)
resource "aws_vpc" "my-first-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {

    Name = "production"
  }
}


# 2. Create internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-first-vpc.id

  tags = {
    Name = "prod-gateway"
  }
}

# 3. Create Custom Route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.my-first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-route-table"
  }
}

# 4. Create a subnet 
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.my-first-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-first-vpc.id

  tags = {
    Name = "allow_tls_web_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  description = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  description = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  description = "SSH"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
  security_group_id = aws_security_group.allow_web.id
  description = "HTTPS"
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.allow_web.id
  description = "HTTP"
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.allow_web.id
  description = "SSH"
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 7.Create a newtwork interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8.Assign an elastic ip to the network interface created in step 7
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw] 
}

# 9. Create Amazon-Linux instance and install/enable apache2
resource "aws_instance" "web_server_instance" { ## The name here is used with in our terraform
  ami = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "terraform-main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web_server_nic.id
  }

  user_data = <<-EOF
                #! /bin/bash
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "The page was created by the user data" | sudo tee /var/www/html/index.html
                EOF

  tags = {
    Name = "web-server"
  }
}
output "server_private_id" {
  value = aws_instance.web_server_instance.private_ip
}

resource "aws_s3_bucket" "product_bucket" {
  bucket = "terraform-productdb"  # Bucket name
  acl    = "private"               # Set the ACL (access control list)

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "bronze_layer" {
  bucket = aws_s3_bucket.product_bucket.bucket
  key    = "bronze/"
  acl    = "private"
}

# Policy to allow read and write access for a specific IAM user
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.product_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::637423439776:user/Terraform-user"  # Replace with your IAM user ARN
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.product_bucket.arn}/*"
      }
    ]
  })
}


/*
resource "aws_s3_bucket" "student_bucket" {
  bucket = "unique-studentterraform-bucket-name"
  acl    = "private"  # Set ACL directly here
  tags = {
    Name        = "studentBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "bronze_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "bronze/"
  acl    = "private"
}

resource "aws_s3_bucket_object" "silver_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "silver/"
  acl    = "private"
}

resource "aws_s3_bucket_object" "gold_layer" {
  bucket = aws_s3_bucket.student_bucket.bucket
  key    = "gold/"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.student_bucket.bucket
}
*/

### Commands
# terraform init
# terraform plan
# terraform apply --auto approve