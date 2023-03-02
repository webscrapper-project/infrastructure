# Web Scrapper Infrastructure at AWS
#### You can see whole infrastructure design in docs folder. (Be sure you add drawio extension in your Code Editor)

## Prerequisites
- Set the credentials for the AWS CLI using either the `aws configure` command or using environment variables (see https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
- Create an S3 bucket `web-scrapper-state` to hold the Terraform state
- Create a DynamoDB table `web-scrapper-state` to synchronize Terraform execution

### 1. First You should deploy VPC and Jenkins resources into AWS:
    cd jenkinsAndVpc
    terraform plan
    terraform apply
### 2. After deploying VPC and Jenkins ECS, you should create repository at ECR. Then you need to register your local docker into AWS ECR:
    aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
### 3. Enter *kubernetes_manifests/backend* folder, update your deployment.yml/container/image with your ECR image which you crated in 2nd step
### 4. Deploy kubernetes resources into AWS:
    cd jenkinsAndVpc
    terraform plan
    terraform apply
### 5. After Deploy all resources into AWS, you can deploy kubernetes manifests in below stages:

# Usage

- ### **After run this command, you can work with kubectl tool for apply kubernetes configuration**
      aws eks --region us-east-1 update-kubeconfig --name web-scrapper-cluster
- ### In main folder, you can run this command to apply deployments for mongodb
        cd kubernetes-manifests
        kubectl apply -f mongodb/
- ### For the first stage you deploy also backend but, it will be deployed through Jenkins Pipeline later:
        kubectl apply -f backend/
- ### You can get cluster URL with this command, using this url you can reach website APIs:
      kubectl get ing -n dev
