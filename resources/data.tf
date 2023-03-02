data "terraform_remote_state" "jenkins_and_vpc_state" {
  backend = "s3"

  config = {
    bucket  = var.terraform_jenkins_and_vpc_state_bucket_name
    key     = var.terraform_jenkins_and_vpc_state_bucket_key
    region  = var.aws_region
    encrypt = true
  }
}