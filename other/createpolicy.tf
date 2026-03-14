#############################
# Terragrunt run --all apply policy
#############################
{
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
				"ecr:GetRegistryScanningConfiguration",
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
				"acm:DescribeCertificate",
				"acm:ListTagsForCertificate"
			],
			"Resource": "arn:aws:acm:${Region}:${Account}:certificate/${CertificateId}"
		},
		{
			"Effect": "Allow",
			"Action": "cloudtrail:GetTrailStatus",
			"Resource": "arn:aws:cloudtrail:${Region}:${Account}:trail/${TrailName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"config:DescribeConfigurationRecorderStatus",
				"config:DescribeConfigurationRecorders"
			],
			"Resource": "arn:aws:config:${Region}:${Account}:configuration-recorder/${RecorderName}/${RecorderId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AttachInternetGateway",
				"ec2:CreateInternetGateway"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:internet-gateway/${InternetGatewayId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AssociateRouteTable",
				"ec2:CreateRoute",
				"ec2:CreateRouteTable"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:route-table/${RouteTableId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AuthorizeSecurityGroupEgress",
				"ec2:AuthorizeSecurityGroupIngress",
				"ec2:CreateSecurityGroup",
				"ec2:RevokeSecurityGroupEgress"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:security-group/${SecurityGroupId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:CreateSubnet",
				"ec2:ModifySubnetAttribute"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:subnet/${SubnetId}"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:CreateVpcEndpoint",
			"Resource": "arn:aws:ec2:${Region}:${Account}:vpc-endpoint/${VpcEndpointId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:AttachInternetGateway",
				"ec2:CreateRouteTable",
				"ec2:CreateSubnet",
				"ec2:CreateVpc",
				"ec2:CreateVpcEndpoint",
				"ec2:DescribeVpcAttribute",
				"ec2:ModifyVpcAttribute"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:vpc/${VpcId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:DescribeImages",
				"ecr:DescribeRepositories",
				"ecr:GetLifecyclePolicy",
				"ecr:ListTagsForResource"
			],
			"Resource": "arn:aws:ecr:${Region}:${Account}:repository/${RepositoryName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:CreateCluster",
				"ecs:DescribeClusters"
			],
			"Resource": "arn:aws:ecs:${Region}:${Account}:cluster/${ClusterName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:CreateService",
				"ecs:DescribeServices"
			],
			"Resource": "arn:aws:ecs:${Region}:${Account}:service/${ClusterName}/${ServiceName}"
		},
		{
			"Effect": "Allow",
			"Action": "ecs:RegisterTaskDefinition",
			"Resource": "arn:aws:ecs:${Region}:${Account}:task-definition/${TaskDefinitionFamilyName}:${TaskDefinitionRevisionNumber}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticloadbalancing:AddTags",
				"elasticloadbalancing:ModifyLoadBalancerAttributes"
			],
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:loadbalancer/${LoadBalancerName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticloadbalancing:CreateTargetGroup",
				"elasticloadbalancing:ModifyTargetGroupAttributes"
			],
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:targetgroup/${TargetGroupName}/${TargetGroupId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"kms:CreateGrant",
				"kms:DescribeKey"
			],
			"Resource": "arn:aws:kms:${Region}:${Account}:key/${KeyId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:PutRetentionPolicy"
			],
			"Resource": "arn:aws:logs:${Region}:${Account}:log-group:${LogGroupName}"
		},
		{
			"Effect": "Allow",
			"Action": "resource-explorer-2:Search",
			"Resource": "arn:aws:resource-explorer-2:${Region}:${Account}:view/${ViewName}/${ViewUuid}"
		}
	]
}