provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "novasphere"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
