variable "environment" {
  description = "Environnement de deploiement"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC dans lequel deployer la stack web"
  type        = string
}

variable "public_subnet_ids" {
  description = "Liste des subnets publics utilises par l'ALB et l'ASG"
  type        = list(string)
}

variable "instance_type" {
  description = "Type d'instance EC2 utilise pour les serveurs web"
  type        = string
}

variable "ami_id" {
  description = "ID de l'AMI utilisee par les instances web"
  type        = string

  validation {
    condition     = startswith(var.ami_id, "ami-")
    error_message = "ami_id doit commencer par ami-."
  }
}

variable "iam_instance_profile_name" {
  description = "Nom du profil IAM attache aux instances EC2"
  type        = string
  default     = "LabInstanceProfile"
}

variable "asg_min_size" {
  description = "Nombre minimum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Nombre maximum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Nombre d'instances souhaite dans l'Auto Scaling Group"
  type        = number
  default     = 2
}
