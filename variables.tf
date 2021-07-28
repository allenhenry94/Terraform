variable "cidr_block" {
    type = list(string)
    default = ["172.20.0.0/16","172.20.0.0/24"]
  
}

variable "ports" {
    type = list(number)
    default = [22,80,443,8080,8081]
}

variable "ami" {
    type = string
    default = "ami-063d4ab14480ac177"
  
}

variable "instance_type" {
    type = string
    default = "t2.micro"
  
}