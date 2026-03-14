#############################
# Terragrunt run --all destroy policy
#############################

{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"cloudtrail:ListTrails",
				"cloudtrail:LookupEvents",
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
				"ecs:DeregisterTaskDefinition",
				"ecs:DescribeTaskDefinition",
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
			"Resource": "arn:aws:acm:${Region}:${Account}:certificate/${CertificateId}"
		},
		{
			"Effect": "Allow",
			"Action": "cloudtrail:GetTrail",
			"Resource": "arn:aws:cloudtrail:${Region}:${Account}:trail/${TrailName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DeleteInternetGateway",
				"ec2:DetachInternetGateway"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:internet-gateway/${InternetGatewayId}"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:DeleteRouteTable",
			"Resource": "arn:aws:ec2:${Region}:${Account}:route-table/${RouteTableId}"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:DeleteSecurityGroup",
			"Resource": "arn:aws:ec2:${Region}:${Account}:security-group/${SecurityGroupId}"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:DeleteSubnet",
			"Resource": "arn:aws:ec2:${Region}:${Account}:subnet/${SubnetId}"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:DeleteVpcEndpoints",
			"Resource": "arn:aws:ec2:${Region}:${Account}:vpc-endpoint/${VpcEndpointId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DeleteVpc",
				"ec2:DescribeVpcAttribute",
				"ec2:DetachInternetGateway"
			],
			"Resource": "arn:aws:ec2:${Region}:${Account}:vpc/${VpcId}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:DeleteCluster",
				"ecs:DescribeClusters"
			],
			"Resource": "arn:aws:ecs:${Region}:${Account}:cluster/${ClusterName}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecs:DeleteService",
				"ecs:DescribeServices",
				"ecs:UpdateService"
			],
			"Resource": "arn:aws:ecs:${Region}:${Account}:service/${ClusterName}/${ServiceName}"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:listener/app/${LoadBalancerName}/${LoadBalancerId}/${ListenerId}"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:listener/gwy/${LoadBalancerName}/${LoadBalancerId}/${ListenerId}"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteListener",
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:listener/net/${LoadBalancerName}/${LoadBalancerId}/${ListenerId}"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteLoadBalancer",
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:loadbalancer/${LoadBalancerName}"
		},
		{
			"Effect": "Allow",
			"Action": "elasticloadbalancing:DeleteTargetGroup",
			"Resource": "arn:aws:elasticloadbalancing:${Region}:${Account}:targetgroup/${TargetGroupName}/${TargetGroupId}"
		},
		{
			"Effect": "Allow",
			"Action": "logs:DeleteLogGroup",
			"Resource": "arn:aws:logs:${Region}:${Account}:log-group:${LogGroupName}"
		}
	]
}