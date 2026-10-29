output "alb_dns_name" {
  description = "Nom DNS public de l'Application Load Balancer"
  value       = module.web.alb_dns_name
}
