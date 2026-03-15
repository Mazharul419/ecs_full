resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name = "github-actions-oidc"
  }
}

# Data source for account ID
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"
  max_session_duration = 7200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    Name = "github-actions-role"
  }
}

# Github actions policy for ECR access
resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "github-actions-ecr-policy"
  role = aws_iam_role.github_actions.id

policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken"
      ]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:ListImages",
        "ecr:DescribeRepositories"
      ]
      Resource = [
        "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}",
        "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"
      ]
    },
    {
      Sid    = "AllowPassRole"
      Effect = "Allow"
      Action = [
        "iam:PassRole"
      ]
      Resource = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-*-ecs-execution-role",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-*-ecs-task-role"
      ]
      Condition = {
        StringEquals = {
          "iam:PassedToService" = "ecs-tasks.amazonaws.com"
        }
      }
    }
  ]
})
}

# ECS Deploy Policy (if you also deploy from GitHub Actions)
resource "aws_iam_role_policy" "github_actions_ecs" {
  name = "github-actions-ecs-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*-ecs-execution",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*-ecs-task"
        ]
      }
    ]
  })
}

# Terragunt deploy Policy (permissions for running terragrunt apply and destroy)

resource "aws_iam_role_policy" "github_actions_terragrunt" {
  name = "github-actions-terragrunt-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({

	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"acm:RequestCertificate",
				"cloudtrail:DescribeTrails",
				"cloudtrail:ListEventDataStores",
				"cloudtrail:ListTrails",
				"cloudtrail:LookupEvents",
				"ec2:CreateTags",
				"ec2:DescribeAvailabilityZones",
				"ec2:DescribeInternetGateways",
				"ec2:DescribeNetworkAcls",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DescribePrefixLists",
				"ec2:DescribeRegions",
				"ec2:DescribeRouteTables",
				"ec2:DescribeSecurityGroups",
				"ec2:DescribeSubnets",
				"ec2:DescribeVpcEndpoints",
				"ec2:DescribeVpcs",
				"ec2:DisassociateRouteTable",
				"ecr:GetRegistryScanningConfiguration",
				"ecs:DeregisterTaskDefinition",
				"ecs:DescribeTaskDefinition",
				"elasticloadbalancing:CreateListener",
				"elasticloadbalancing:CreateLoadBalancer",
				"elasticloadbalancing:DescribeCapacityReservation",
				"elasticloadbalancing:DescribeListenerAttributes",
				"elasticloadbalancing:DescribeListeners",
				"elasticloadbalancing:DescribeLoadBalancerAttributes",
				"elasticloadbalancing:DescribeLoadBalancers",
				"elasticloadbalancing:DescribeTags",
				"elasticloadbalancing:DescribeTargetGroupAttributes",
				"elasticloadbalancing:DescribeTargetGroups",
				"logs:DescribeLogGroups",
				"logs:ListTagsForResource",
				"resource-explorer-2:ListIndexes",
				"route53:AssociateVPCWithHostedZone",
				"sts:GetCallerIdentity"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"acm:DeleteCertificate",
				"acm:DescribeCertificate",
				"acm:ListTagsForCertificate"
			],
			"Resource": "arn:aws:acm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:certificate/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"cloudtrail:GetTrail",
				"cloudtrail:GetTrailStatus"
			],
			"Resource": "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"config:DescribeConfigurationRecorderStatus",
				"config:DescribeConfigurationRecorders"
			],
			"Resource": "arn:aws:config:${var.aws_region}:${data.aws_caller_identity.current.account_id}:configuration-recorder/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AttachInternetGateway",
				"ec2:CreateInternetGateway",
				"ec2:DeleteInternetGateway",
				"ec2:DetachInternetGateway"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:internet-gateway/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AssociateRouteTable",
				"ec2:CreateRoute",
				"ec2:CreateRouteTable",
				"ec2:DeleteRouteTable"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:route-table/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AuthorizeSecurityGroupEgress",
				"ec2:AuthorizeSecurityGroupIngress",
				"ec2:CreateSecurityGroup",
				"ec2:DeleteSecurityGroup",
				"ec2:RevokeSecurityGroupEgress"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:security-group/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:CreateSubnet",
				"ec2:DeleteSubnet",
				"ec2:ModifySubnetAttribute"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:subnet/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:CreateVpcEndpoint",
				"ec2:DeleteVpcEndpoints"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc-endpoint/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AttachInternetGateway",
				"ec2:CreateRouteTable",
				"ec2:CreateSubnet",
				"ec2:CreateVpc",
				"ec2:CreateVpcEndpoint",
				"ec2:DeleteVpc",
				"ec2:DescribeVpcAttribute",
				"ec2:DetachInternetGateway",
				"ec2:ModifyVpcAttribute"
			],
			"Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:DescribeImages",
				"ecr:DescribeRepositories",
				"ecr:GetLifecyclePolicy",
				"ecr:ListTagsForResource"
			],
			"Resource": "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:CreateCluster",
				"ecs:DeleteCluster",
				"ecs:DescribeClusters"
			],
			"Resource": "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:CreateService",
				"ecs:DeleteService",
				"ecs:DescribeServices",
				"ecs:UpdateService"
			],
			"Resource": "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/*"
		},
		{
			"Effect": "Allow",
			"Action": "ecs:RegisterTaskDefinition",
			"Resource": "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/*:*"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:listener/app/*/*"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:listener/gwy/*/*/*"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:listener/net/*/*/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticloadbalancing:AddTags",
				"elasticloadbalancing:DeleteLoadBalancer",
				"elasticloadbalancing:ModifyLoadBalancerAttributes"
			],
			"Resource": "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:loadbalancer/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticloadbalancing:CreateTargetGroup",
				"elasticloadbalancing:DeleteTargetGroup",
				"elasticloadbalancing:ModifyTargetGroupAttributes"
			],
			"Resource": "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"kms:CreateGrant",
				"kms:DescribeKey"
			],
			"Resource": "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:DeleteLogGroup",
				"logs:PutRetentionPolicy"
			],
			"Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"
		},
		{
			"Effect": "Allow",
			"Action": "resource-explorer-2:Search",
			"Resource": "arn:aws:resource-explorer-2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:view/*/*"
		}
	]
})
}