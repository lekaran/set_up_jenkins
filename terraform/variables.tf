variable "aws_region" {
  description = "This is the region where we deploy services on AWS"
  type        = string
  default     = "eu-west-1"
}

variable "project_tags" {
  description = "This is the tags we'll put on all ours AWS Services"
  type = object({
    Name    = string
    Project = string
    Owner   = string
    # Date    = string
  })
  default = {
    Name    = "default_name_service"
    Project = "Deploy_Jenkins"
    Owner   = "Michael RANIVO"
    # je n'ai pas mis Date parce qu'à chaque fois que je vais faire un plan, cela va toujours mettre à jour tag des services!!!
  }
}

############### VPC ###############

variable "aws_vpc_cidr" {
  description = "This define the CIDR of the AWS VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "aws_subnet_cidr" {
  description = "This define the CIDR of the AWS Subnet"
  type        = string
  default     = "10.0.0.0/25"
}

############### EC2 ###############

variable "aws_ec2_type" {
  description = "This define the type of the instance EC2"
  type        = string
  default     = "t3.small"
}

variable "aws_kp_name" {
  description = "This define the name of the Key pair that will use the instance EC2"
  type        = string
}

variable "aws_ec2_public_key" {
  description = "This define the public key for the key pair used by the instance EC2"
  type        = string
}