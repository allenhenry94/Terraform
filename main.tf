terraform {
  required_providers {
     aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
      }
  }
}

#Configure the aws provider using the provider block
#The first two blocks need to be written only once
provider "aws" {
    region = "eu-west-1"
    #Mentioning the 'access key' and the 'secret key' is not a good practice because they are viewed to be sensitiv data
    #Hence we configure the keys using aws cli
  
}

#Create a VPC resource
resource "aws_vpc" "MyLab-VPC" {
    cidr_block = var.cidr_block[0] #variable fetched from the 'cidr_block' 'variable.tf' file

    tags = {
      Name = "MyLab-VPC"
    }
 
}

#Create a Subnet (Public)
resource "aws_subnet" "MyLab-Subnet1" {
    vpc_id=aws_vpc.MyLab-VPC.id 
    #dynamically created vpc_id
    cidr_block = var.cidr_block[1] #variable fetched from the 'cidr_block' 'variable.tf' file

    tags={
        Name="MyLab-Subnet1"
    }
}

#Create an Internet Gateway
resource "aws_internet_gateway" "MyLab-IntGW" {
    vpc_id = aws_vpc.MyLab-VPC.id

    tags = {
      Name = "MyLab-InternetGW"
    }
  
}


#create a security group

#We would be using 'Dynamic Blocks'. A Dynamic Block is used to dynamically create multiple instances of a block w/n a resource
resource "aws_security_group" "MyLab-SG" {
    name = "MyLab Security Group"
    description = "To allow inbound and outbound traffic to MyLab"
    vpc_id = aws_vpc.MyLab-VPC.id

    dynamic ingress {
        iterator = port
        for_each = var.ports
         content{
                     from_port=port.value
                     to_port=port.value
                     protocol="tcp"
                     cidr_blocks=["0.0.0.0/0"]
         }


    }

    egress {
        #The outbound server must be able to communicate with all servers
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]

        
    }

        tags = {
          Name = "allow traffic"
        }
    }


#Create a route table and  and route table association
#We first create a route table 

resource "aws_route_table" "MyLab-RoutingTable" {
    vpc_id = aws_vpc.MyLab-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.MyLab-IntGW.id
    }

    tags = {
      "Name" = "MyLab-RouteTable"
    }
  
}


#Then we create the route table association
resource "aws_route_table_association" "MyLab-assoc" {
    subnet_id = aws_subnet.MyLab-Subnet1.id
    route_table_id = aws_route_table.MyLab-RoutingTable.id
  
}


#Create an EC2 instance 

resource "aws_instance" "DemoResource" {
  ami           = var.ami
  instance_type = var.instance_type 
  key_name = "technosapien_keypair"
  vpc_security_group_ids = [aws_security_group.MyLab-SG.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true


  tags = {
    Name = "DemoInstance"
  }

}