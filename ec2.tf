# Genera par de claves TLS (privada y pública)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Crea el key pair en AWS con la clave pública generada
resource "aws_key_pair" "ec2_redhat_key" {
  key_name   = "ec2-redhat-test-keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Guarda la clave privada localmente para usar en SSH
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/ec2-redhat-test-keypair.pem" # nombre consistente con keypair
  file_permission = "0400"
}


module "ec2_test" {
  source            = "github.com/Coalfire-CF/terraform-aws-ec2"
  name              = var.instance_name
  ami               = data.aws_ami.redhat.id
  ec2_instance_type = var.instance_type
  instance_count    = var.instance_count

  vpc_id     = module.vpc_nfw.vpc_id
  subnet_ids = [module.vpc_nfw.public_subnets[1]] # --> Subnet2


  #ec2_key_pair    = var.key_name
  ec2_key_pair    = aws_key_pair.ec2_redhat_key.key_name
  ebs_kms_key_arn = data.terraform_remote_state.kms.outputs.ebs_kms_key_arn

  # Storage
  root_volume_size = var.instance_volume_size

  # Security Group Rules
  ingress_rules = {
    "ssh" = {
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = var.cidr_for_remote_access
      description = "SSH access"
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      from_port   = 0
      to_port     = 0
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }


  # Tagging
  global_tags = {}
}