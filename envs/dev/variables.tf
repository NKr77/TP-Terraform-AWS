variable "region" {
  description = "Région AWS (us-east-1 imposée par le Learner Lab)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nom de l'environnement, utilisé dans tous les noms de ressources"
  type        = string
  default     = "dev"

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
