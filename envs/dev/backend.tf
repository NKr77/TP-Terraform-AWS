terraform {
  backend "s3" {
    bucket       = "novasphere-tfstate-nkr"
    key          = "novasphere/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # verrou natif S3 (.tflock), pas de DynamoDB
  }
}
