output "jenkins_public_url" {
  description = "Public URL to access Jenkins"
  value       = module.ecs-jenkins.jenkins_public_url
}

output "controller_log_group" {
  description = "Jenkins controller log group"
  value       = module.ecs-jenkins.controller_log_group
}

output "agents_log_group" {
  description = "Jenkins agents log group"
  value       = module.ecs-jenkins.agents_log_group
}

output "jenkins_credentials" {
  description = "Credentials to access Jenkins via the public URL"
  sensitive   = true
  value = module.ecs-jenkins.jenkins_credentials
}

output "controller_config_on_s3" {
  description = "Jenkins controller configuration file on S3"
  value       = module.ecs-jenkins.controller_config_on_s3
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.vpc_private_subnets
}

output "public_subnets" {
  value = module.vpc.vpc_public_subnets
}