# Intro

This is documentation for the ECS-Forge repo - it contains docs related to all the code set up for this project.

## Table of Contents

[Traffic Flow Explained](https://github.com/Mazharul419/ECS-Forge/edit/main/documentation/README.md#traffic-flow-explained)
<br>
&nbsp; [Access to website](https://github.com/Mazharul419/ECS-Forge/edit/main/documentation/README.md#access-to-website)
<br>
&nbsp; [Load Balancer and remaining](https://github.com/Mazharul419/ECS-Forge/edit/main/documentation/README.md#load-balancer-and-remaining)
<br><br>
[Technology Stack Explained](https://github.com/Mazharul419/ECS-Forge/edit/main/documentation/README.md#technology-stack-explained)
<br>
&nbsp; [Infrastructure as Code Tools]()
<br>
&nbsp; [Terraform]()
<br>
&nbsp; [Terragrunt]()
<br>
&nbsp; [AWS Services Used]()
<br><br>
[Project Structure]()
<br>
[Dockerfile, LICENSE, README.md, and App](https://github.com/Mazharul419/ECS-Forge/edit/main/documentation/README.md#dockerfile-license-readmemd)
&nbsp;<br>
[]()
<br>
[]()


# Traffic Flow Explained

## Access to website

![image](https://capacities-files.s3.eu-central-1.amazonaws.com/private/ce5be6b9-2b98-4142-bb70-1cabd8dc3727/raw.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIA5VTNRR6EBR56K2NK%2F20260329%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20260329T093514Z&X-Amz-Expires=43200&X-Amz-Signature=a9b805365e3f128274138b6b9b7d2afe99eb2155becb4f62c5feaff5839c6b7f&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)



To access the live application in production environment, the user types in ***tm.mazharulislam.dev***(or ***tm-dev.mazharulislam.dev*** if accessing development environment).

A DNS (Domain Name System) query takes place - the client sends out tm.mazharulislam.dev and receives the IP address of the public-facing Application Load Balancer (ALB) allowing it to connect to the application hosted in AWS.

![image](https://capacities-files.s3.eu-central-1.amazonaws.com/private/8756b937-d7ab-48cd-8576-1f2925e75a22/raw.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIA5VTNRR6EBR56K2NK%2F20260329%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20260329T110405Z&X-Amz-Expires=43200&X-Amz-Signature=8a1480f580893048151797a17c7fceb96af6081edf8761e6115bc12be3366c61&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)
[image - Notes](https://app.capacities.io/842d982e-dafe-4919-b038-f1da4582566c/8756b937-d7ab-48cd-8576-1f2925e75a22)


Assuming there is no cache stored at any stage - [the following](https://www.cloudflare.com/en-gb/learning/dns/what-is-dns/) will happen:

1. User types in "tm.mazharulislam.dev" - the client checks locally to see if the IP address is cached - within it's browser, or the OS

2. The query travels into the Internet and is received by a DNS resolver

3. The root server responds with the address of a Top Level Domain (TLD) DNS server .dev

4. The resolver then makes a request to the TLD server carrying .dev domain which responds with the IP address of the domain’s nameserver mazharulislam.dev

5. The resolver sends a query to the domain’s nameserver - since a subdomain **tm** is present there is an [additional nameserver](https://www.cloudflare.com/en-gb/learning/dns/what-is-dns/#:~:text=It%E2%80%99s%20worth%20mentioning%20that%20in%20instances%20where%20the%20query%20is%20for%20a%20subdomain%20such%20as%20foo.example.com%20or%20blog.cloudflare.com%2C%20an%20additional%20nameserver%20will%20be%20added%20to%20the%20sequence%20after%20the%20authoritative%20nameserver%2C%20which%20is%20responsible%20for%20storing%20the%20subdomain%E2%80%99s%20CNAME%20record.) which holds the CNAME record

6. The [CNAME](https://developers.cloudflare.com/dns/manage-dns-records/reference/dns-record-types/#:~:text=CNAME%20records%20%E2%86%97%20map%20a%20domain%20name%20to%20another%20(canonical)%20domain%20name.%20They%20can%20be%20used%20to%20resolve%20other%20record%20types%20present%20on%20the%20target%20domain%20name.) is mapped to the Application Load Balancer (ALB) DNS name which is returned to the resolver from the nameserver

7. The authoritative name server responds to the DNS resolver with the CNAME record which includes the DNS name of the load balancer*

8. This record is forwarded to the client

9. Client makes a new query for the ALB CNAME

10. The resolver forwards to amazonaws.com domain where the A record is hosted

11. A record containing the [IP addresses of the ALB nodes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#w2aab7c21:~:text=The%20Application%20Load%20Balancer%20has%20one%20IP%20address%20per%20enabled,determine%20the%20IP%20addresses%20of%20the%20Application%20Load%20Balancer%20nodes.) is returned to DNS resolver

12. DNS resolver finally returns the IP address of the ALB, allowing the client to send a HTTP request in order to connect to the code-server application



*If the apex zone mazharulislam.dev was used instead (by replacing **tm** with **@**), Cloudflare can return the ALB IP address via a process called [CNAME flattening](https://developers.cloudflare.com/dns/cname-flattening/)(see also [Flattening diagram](https://app.capacities.io/842d982e-dafe-4919-b038-f1da4582566c/8e0ae074-62d8-4d95-8335-f011e0c8108e))



# Load Balancer and remaining

Use this section to explain flow from ALB to tasks in private subnet

Also explain how applications can access AWS services privately

---



# Technology Stack Explained

## Infrastructure as Code Tools

## Terraform

## Terragrunt

## AWS Services Used

# Project Structure

```
.
├── Dockerfile
├── LICENSE
├── README.md
├── app
├── architecture
│   └── decisions.md
├── documentation
│   └── README.md
├── infrastructure
│   ├── backend.tf
│   ├── bootstrap
│   │   ├── ReadMe.md
│   │   ├── bootstrap.sh
│   │   └── destroy.sh
│   ├── live
│   │   ├── _env
│   │   │   └── common.hcl
│   │   ├── dev
│   │   │   ├── acm
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── alb
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── dns
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── ecs
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── env.hcl
│   │   │   ├── security-groups
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── vpc
│   │   │   │   └── terragrunt.hcl
│   │   │   └── vpc-endpoints
│   │   │       └── terragrunt.hcl
│   │   ├── global
│   │   │   ├── ecr
│   │   │   │   └── terragrunt.hcl
│   │   │   └── oidc
│   │   │       └── terragrunt.hcl
│   │   └── prod
│   │       ├── acm
│   │       │   └── terragrunt.hcl
│   │       ├── alb
│   │       │   └── terragrunt.hcl
│   │       ├── dns
│   │       │   └── terragrunt.hcl
│   │       ├── ecs
│   │       │   └── terragrunt.hcl
│   │       ├── env.hcl
│   │       ├── security-groups
│   │       │   └── terragrunt.hcl
│   │       ├── vpc
│   │       │   └── terragrunt.hcl
│   │       └── vpc-endpoints
│   │           └── terragrunt.hcl
│   ├── modules
│   │   ├── acm
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── alb
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── dns
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── ecr
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── ecs
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── oidc
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── security-groups
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── vpc
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── vpc-endpoints
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── provider.tf
│   └── terragrunt.hcl
└── other
    ├── both.tf
    ├── createpolicy.tf
    └── deletepolicy.tf
```

## Structure Explained

### Dockerfile, LICENSE, README.md, and App

```
├── Dockerfile
├── LICENSE
├── README.md
├── app
```

According to [Docker docs](https://docs.docker.com/reference/dockerfile/) the Dockerfile is a text file that contains all the commands that a user would run on a command line that tells Docker to build the image. 
<br>
The ReadME.md file is for any person visiting the repo to understand at a high level what the project does and how they can set this up for themselves.
<br>
The LICENSE.txt file specifies how the repo can be distributed and used.
<br>
The app directory contains the application itself - though it is not used in the Dockerfile (due to issues with git submodules not pulling the application properly)

5. Root Configuration (terragrunt.hcl)
File Location
Locals Block
Remote State Block
Generate Provider Block


6. Terraform Modules
6.1 VPC Module
Data Source: Availability Zones
VPC Resourcs
Public Subnets
Private Subnets
Public Route Table
Private Route Tables
Internet Gateway
6.2 Security Groups Module
ALB Security Group
ECS Security Group
VPC Endpoints Security Group
6.3 VPC Endpoints Module
Cost Comparison: NAT Gateway vs VPC Endpoints
S3 Gateway Endpoint (FREE)
ECR API Endpoint
ECR DKR Endpoint
CloudWatch Logs Endpoint
6.4 ACM (Certificate) Module
Certificate Request
DNS Validation Record
Certificate Validation
6.5 ALB (Application Load Balancer) Module
Load Balancer
Target Group
HTTPS Listener
HTTP Listener (Redirect)
6.6 DNS Module
6.7 ECS Module
ECS Concepts
Cluster
CloudWatch Log Group
Task Execution Role
Task Definition
ECS Service
6.8 ECR Module
6.9 OIDC Module
Why OIDC Instead of Access Keys?


7. Live Environment Configurations
Dev Environment (env.hcl)
Prod Environment (env.hcl)
Terragrunt Dependencies


8. CI/CD Pipelines (GitHub Actions)
Key CI/CD Sections
OIDC Permissions
AWS Authentication
Task Definition Update


9. Dockerfile Explained
Stage 1: Build
Stage 2: Runtime
10. Bootstrap Script
The 9 Steps
Usage


11. Supporting Configuration Files	37
.env.example
.gitignore Highlights
.dockerignore


12. Glossary of Terms




