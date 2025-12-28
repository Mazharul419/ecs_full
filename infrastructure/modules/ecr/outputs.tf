output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.main.name
}

output "docker_push_commands" {
  description = "Commands to push to ECR"
  value = <<-EOT


    #####🐋 Docker Push Commands 🐋#####


    ## Login to ECR ##
    aws ecr get-login-password --region ${data.aws_region.current.id} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}


    ## Build image ##
    docker build -t ${aws_ecr_repository.main.name} .


    ## Tag image ##
    docker tag ${aws_ecr_repository.main.name}:latest ${aws_ecr_repository.main.repository_url}:latest


    ## Push image ##
    docker push ${aws_ecr_repository.main.repository_url}:latest
  EOT
}