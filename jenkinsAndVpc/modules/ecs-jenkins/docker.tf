resource "docker_registry_image" "jenkins" {
    name = local.controller_docker_image
    build {
        context = "modules/ecs-jenkins/docker"
        build_args = {
            JENKINS_VERSION: var.jenkins_version
        }
        auth_config {
          host_name = split("/", var.repo_url)[0]
          server_address = var.repo_token.proxy_endpoint
        }
    }
}

// TODO build jenkins agent docker image and push to registry