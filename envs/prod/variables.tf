variable "region" {
  description = "Région AWS (us-east-1 imposée par le Learner Lab)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nom de l'environnement, utilisé dans tous les noms de ressources"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment doit valoir dev ou prod."
  }
}

variable "instance_type" {
  description = "Type d'instance EC2 utilise pour les serveurs web"
  type        = string
  default     = "t3.micro"
}

# Debian 12 (20260923-2610) : meme AMI que dev, figee
variable "ami_id" {
  description = "AMI Debian 12 figee pour l'environnement prod"
  type        = string
  default     = "ami-089045d4bb5fcc5d6"
}
