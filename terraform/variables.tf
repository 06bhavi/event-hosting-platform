variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for resource names"
  type        = string
  default     = "event-platform"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/event-platform-key.pub"
}

variable "allowed_ssh_cidr" {
  description = "Who can SSH. Use your_ip/32 for safety"
  type        = string
  default     = "0.0.0.0/0"
}
