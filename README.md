## Description

This project implements an infrastructure on AWS using Terraform with standalone and modular deployments, as part of a technical challenge for GlobalLogic.

The solution includes:

- Provisioning of a (**VPC**) with public and private subnets distributed across multiple availability zones.
- Automatic deployment of EC2 instances using **Auto Scaling Groups (ASG)** with load balancing configuration.
- Implementation of an **Application Load Balancer (ALB)** that exposes the application to the public on port 80 and redirects internal traffic to port 443.
- Definition of **custom IAM roles** with specific permissions for bucket access and log generation.
- Configuration of **S3 buckets** with object lifecycle and expiration rules for image and log storage.

The environment was developed following IaC best practices.


# Solution Overview

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

```bash
cd Bootstrap/
chmod +x bootstrap.sh
./bootstrap.sh
```
![Bootstrap folder](Docs/assets/Bootstrap_folder.png)

---

## 🧪 VPC

- Basado en módulo público Coalfire [`terraform-aws-vpc-nfw`](https://github.com/Coalfire-CF/terraform-aws-vpc-nfw)

### Comandos

```bash
cd VPC/
terraform init
terraform plan
terraform apply
```

> Despliegue **independiente**, manteniendo la VPC activa aunque otros recursos se eliminen.

---

## 🧪 EC2 Instance

- Despliegue independiente
- Usada potencialmente como **bastion host**

### Comandos

```bash
cd EC2/
terraform init
terraform plan
terraform apply
```

> Se genera un keypair que deja el archivo `.pem` localmente. Se debe mover a una bóveda segura (ej. AWS Secrets Manager).

---

## 🧪 HTTPD_ASG

- Despliega ASG, ALB, buckets S3, roles IAM y SGs

### Comandos

```bash
cd EC2/
terraform init
terraform plan
terraform apply
```

---

## 🎯 Design Decisions

- **Backend remoto**: Bootstrap automatizado (S3 + DynamoDB + KMS)
- **VPC persistente**: se mantiene fuera de la cadena de recursos
- **EC2 desacoplada**: usada como bastion o instancia de pruebas
- **Unificación de IAM roles**: un solo role para lectura de `images` y escritura en `logs`

---

## 🔗 References

- 🧩 Backend remoto: [Terraform Remote State](https://developer.hashicorp.com/terraform/language/state/remote)
- 🧩 Módulo VPC: [`terraform-aws-vpc-nfw`](https://github.com/Coalfire-CF/terraform-aws-vpc-nfw)
- 🧩 EC2: [`terraform-aws-ec2`](https://github.com/Coalfire-CF/terraform-aws-ec2)
- ⚙️ Recursos AWS:
  - [Load Balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
  - [Target Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)
  - [Listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)
  - [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
  - [Auto Scaling Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)
  - [IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
  - [S3 Buckets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
  - [Download Key Pair Locally](https://stackoverflow.com/questions/67389324/create-a-key-pair-and-download-the-pem-file-with-terraform-aws)

---

## ⚠️ Operational Gaps

- ❌ Acceso a EC2 via PEM inseguro, puerto 22 abierto
- ❌ No se usa Session Manager ni bóveda segura
- 📉 No se instala CloudWatch Agent ni se definen Log Groups
- 🔐 IAM Policies están en cada módulo, no centralizadas