# General Variables

variable "app_name" {
  description = "Name of the web application"
  type        = string
  default     = "terraform-deploy-app"
}

# EC2 Variables

variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

# RDS Variables

variable "db_name" {
  description = "Name of DB"
  type        = string
  default     = "testDB"
}

variable "db_user" {
  description = "Username for DB"
  type        = string
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}


