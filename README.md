# 🧩 Solution Overview

Esta solución corresponde a un desafío técnico, cumpliendo con los criterios descritos en el desafío enviado:

## 🔷 VPC

- 4 subnets (spread evenly across two availability zones):
  - `Sub1 – 10.1.0.0/24 (should be accessible from internet)`
  - `Sub2 – 10.1.1.0/24 (should be accessible from internet)`
  - `Sub3 – 10.1.2.0/24 (should NOT be accessible from internet)`
  - `Sub4 – 10.1.3.0/24 (should NOT be accessible from internet)`

## 🔷 EC2 Instance

- Ubicada en subnet **sub2**
- Sistema: **Red Hat Linux**
- Specs: `t2.micro`, `20 GB storage`

## 🔷 Auto Scaling Group (ASG)

- Subnets: `sub3` y `sub4`
- Sistema: **Red Hat Linux**
- Specs: `t2.micro`, mínimo 2 hosts, máximo 6
- Script: instalación de Apache web server (`httpd`)
- IAM Role: acceso de lectura al bucket `images`
- Security Group: permite tráfico necesario

## 🔷 Application Load Balancer (ALB)

- Escucha en puerto **80 (HTTP)**
- Redirige tráfico a ASG en **puerto 443**
- Posicionado frente a las subnets `sub3` y `sub4`

## 🔷 IAM Role Global

- Permite escritura en bucket `logs` desde **todas las EC2s provisionadas**

## 🔷 S3 Buckets

### Bucket: `Images`
- Carpeta: `/archive`
- Carpeta `Memes`: mover objetos >90 días a **Glacier**

### Bucket: `Logs`
- Carpeta `Active`: mover >90 días a **Glacier**
- Carpeta `Inactive`: borrar objetos >90 días

---

# 🚀 Deployment Instructions

## 🧪 Account Bootstrap

> Este script **NO forma parte de los requerimientos**, pero se incluye para inicializar el backend remoto de Terraform.

### Propósito

- Crear entorno para backend remoto con control de estado y locking

### Comandos

```bash
cd Bootstrap/
chmod +x bootstrap.sh
./bootstrap.sh
```

### Recursos creados

- 🔐 Clave KMS con alias y políticas
- 📦 Bucket S3 para estados de Terraform (cifrado KMS)
- 📊 Tabla DynamoDB para locking

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