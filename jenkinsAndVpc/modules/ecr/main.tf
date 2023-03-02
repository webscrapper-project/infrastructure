resource "aws_ecr_repository" "jenkins" {
    name = "jenkins"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {
      scan_on_push = true
    }

    encryption_configuration {
      encryption_type = "KMS"
    }
}

data "aws_ecr_authorization_token" "token" {
}

output "jenkins-repo-url" {
  description = "URL of the Jenkins ECR repository, to be used as image name for images to be pushed here"
  value = aws_ecr_repository.jenkins.repository_url
}

output "ecr-token" {
  description = "Authorization token for accessing the ECR registry"
  value = data.aws_ecr_authorization_token.token
}