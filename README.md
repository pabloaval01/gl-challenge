# Description

This project implements an infrastructure on AWS using Terraform with standalone and modular deployments, as part of a technical challenge for GlobalLogic.

The solution includes:

- Provisioning of a (**VPC**) with public and private subnets distributed across multiple availability zones.
- Automatic deployment of EC2 instances using **Auto Scaling Groups (ASG)** with load balancing configuration.
- Implementation of an **Application Load Balancer (ALB)** that exposes the application to the public on port 80 and redirects internal traffic to port 443.
- Definition of **custom IAM roles** with specific permissions for bucket access and log generation.
- Configuration of **S3 buckets** with object lifecycle and expiration rules for image and log storage.

The environment was developed following IaC best practices.


## Solution Overview

This solution corresponds to a technical challenge, meeting the criteria described in the submitted challenge:

## 🔷 VPC

- 4 subnets (spread evenly across two availability zones):
  - `Sub1 – 10.1.0.0/24 (should be accessible from internet)`
  - `Sub2 – 10.1.1.0/24 (should be accessible from internet)`
  - `Sub3 – 10.1.2.0/24 (should NOT be accessible from internet)`
  - `Sub4 – 10.1.3.0/24 (should NOT be accessible from internet)`

## 🔷 EC2 Instance

- Located in **sub2**
- AMI: **Red Hat Linux**
- Specs: `t2.micro`, `20 GB storage`

## 🔷 Auto Scaling Group (ASG)

- Subnets: `sub3` y `sub4`
- AMI: **Red Hat Linux**
- Specs: `t2.micro`, 2 minimum, 6 maximum hosts
- Script: installing Apache web server (`httpd`)
- IAM Role: read access to the bucket `images`
- Security Group: allows necessary traffic

## 🔷 Application Load Balancer (ALB)

- Listen in port **80 (HTTP)**
- Redirect traffic to ASG in **puerto 443**
- (ALB) listen on TCP port 80 (HTTP) and forwards traffic to the ASG in subnets  `sub3` and `sub4` on port 443 


## 🔷 IAM Role

- Allows writing to the `logs` bucket from auto-scaled EC2s
- Allows reading of the `images` bucket from auto-scaled EC2s

## 🔷 S3 Buckets

### Bucket: `Images`
- Folder: `/archive`
- `Memes` folder: Move objects older than 90 days to **Glacier**

### Bucket: `Logs`
- Active folder: Move >90 days to **Glacier**
- Inactive folder: Delete objects >90 days old

---

# 🚀 Deployment Instructions

## Account Bootstrap

This script is **NOT part of the requirements**, but is included to initialize the Terraform remote backend. It is assumed that the AWS account where the deployment will be performed is a new account, as is my case.


### Purpose

- Create KMS Key with Aliases and Policies.
- Create S3 Bucket for Terraform States with KMS Encryption
- Create a remote backend environment with terraform-state control and locking.
- Create DynamoDB Table for Locking

---

### Execution steps

To deploy it, clone the repository and position yourself in the “Bootstrap” folder.

![Bootstrap folder](docs/assets/folder_bootstrap.png)

```bash
cd Bootstrap/
chmod +x bootstrap.sh
./bootstrap.sh
```

---

## VPC

The VPC module is based on the public Coalfire module [`terraform-aws-vpc-nfw`](https://github.com/Coalfire-CF/terraform-aws-vpc-nfw), which meets all the requirements of the challenge.
This deployment should be the first in the chain and should be done independently, following good infrastructure practices, as it is recommended that the VPC remain active even if other resources are deleted or recreated. 

### Execution steps

To deploy it, clone the repository and position yourself in the “VPC” folder.

![VPC folder](docs/assets/folder_vpc.png)

```bash
cd VPC/
terraform init
terraform plan
terraform apply
```

---

## EC2 Instance

This deployment is based on the public Coalfire module [`terraform-aws-ec2`](https://github.com/Coalfire-CF/terraform-aws-ec2). It runs independently since the challenge interpretation assumes that this instance has no direct influence on the other deployments, so it can be used for any other purpose, such as being a bastion host to access other instances.

### Execution steps

To deploy it, clone the repository and position yourself in the “EC2” folder.

![EC2 folder](docs/assets/folder_ec2.png)

```bash
cd EC2/
terraform init
terraform plan
terraform apply
```

> This deployment generates a unique keypair that allows access to the instance via SSH. The template logic is designed to place the `.pem` file in the local folder of the deployment module. It should be moved to a secure vault (you can use Secrets Manager).

![EC2 folder](docs/assets/folder_ec2_pemfile.png)

---

## HTTPD_ASG

This project implements multiple resources that fully meet the requested requirements. It is modularized to maintain code reusability, scalability, and clarity.

- Main objectives:
    - Create an Auto Scaling Group (ASG) distributed across private subnets. Distribute instances across subnets sub3 and sub4.
    - Create a Launch Template to deploy Red Hat Linux instances with HTTPD.
    - Deploy an Application Load Balancer that accepts HTTP traffic (port 80) from the Internet. It must also redirect incoming traffic to the ASG on port 443.
    - Create S3 buckets for logs and image repositories with specific conditions (Lifecycle Rules and object expiration).
    - Create a role that allows instances launched from the ASG to interact with the previously created buckets.
    - Define specific Security Groups for each component.

### Execution steps

To deploy it, clone the repository and position yourself in the “HTTPD_ASG” folder.

![Httpd folder](docs/assets/folder_http_asg.png)

```bash
cd EC2/
terraform init
terraform plan
terraform apply
```

---

## Design Decisions

- **Remote Backend and Terraform-State Locking**: Bootstrap automatizado (S3 + DynamoDB + KMS):
    - An automated bootstrap was designed to create the remote Terraform backend using an S3 bucket with KMS encryption.
    - A DynamoDB table for lock control.

This ensures security, state versioning, and prevents conflicts in concurrent deployments.

- **VPC Deployment**: It was decided to implement the VPC as a separate deployment from the rest of the resources to ensure that its administration and maintainability are separate from the infrastructure deployment proposed in the challenge.
This same VPC can be used for future projects that need to coexist with the components deployed here. This decision is based on maintaining the VPC as a persistent deployment, even if the rest of the resources are seized.

- **EC2 Deployment**: It was decided that the deployed instance would also be deployed independently. It was assumed that it had functionality and utilization outside of the scalable and resilient structure posed by the challenge. It was considered that it could be used as a test scenario or perhaps a bastion-host instance to access the automated deployment instances.

- **IAM Roles, unified**: The requirements require provisioned instances to be able to read from the `images` bucket, but they also require provisioned instances to be able to write logs to the `logs` bucket. Since a Launch template can technically only assume one Instance Profile, it is considered to do so in a single role.

---

## 🔗 References

- Remote backend: [Terraform Remote State](https://developer.hashicorp.com/terraform/language/state/remote)
- VPC Module: [`terraform-aws-vpc-nfw`](https://github.com/Coalfire-CF/terraform-aws-vpc-nfw)
- EC2: [`terraform-aws-ec2`](https://github.com/Coalfire-CF/terraform-aws-ec2)
- AWS Resources:
  - [Load Balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
  - [Target Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)
  - [Listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)
  - [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
  - [Auto Scaling Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)
  - [IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
  - [S3 Buckets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
  - [Download Key Pair Locally](https://stackoverflow.com/questions/67389324/create-a-key-pair-and-download-the-pem-file-with-terraform-aws)

---

### Improvement Plan

This improvement plan aims to list opportunities to optimize the security, maintainability, scalability, and observability of this project. A series of prioritized actions are proposed to strengthen the design.

- Replace the use of PEM keys with Session Manager.
- Create custom images that include a hardening plan.
- Store the PEM file in a secure location; it can be stored in Secrets Manager or SSM Parameter Store.
- Reuse S3 modules. Two different modules are currently used to create buckets. A customizable module can be created using variables.


## Analysis of Operational Gaps

- Access to EC2 instances: Currently relies on an insecurely stored locally PEM certificate, in addition to having to open port 22 in the Security Group ingress rules. SSM is not used to access instances without relying on the certificate, nor is a secure access PEM storage solution orchestrated.

- Lack of active monitoring and alerting: The Cloudwatch agent is not installed, and Log Groups are not defined to send metrics to CloudWatch. Therefore, any issues may go unnoticed due to the lack of the necessary agents and Log Groups.

- IAM policies are being defined within each module, rather than centralized in a specific module that manages policy deployment and control in a unified manner. This makes it difficult to maintain and scale permissions as the infrastructure grows.