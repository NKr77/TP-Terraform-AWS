# Secret applicatif genere par Terraform.
# ephemeral + value_wo : la valeur n'apparait ni dans le plan ni dans le state.
# Pour changer le secret : incrementer value_wo_version.
ephemeral "random_password" "app_secret" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "app_secret" {
  name             = "/novasphere/${var.environment}/app_secret"
  description      = "Secret applicatif lu au demarrage par les instances web"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.app_secret.result
  value_wo_version = 1
}
