output "vpc_id" {
  description = "VPCID"
  value       = module.vpc_nfw.vpc_id
}

output "private_key_path" {
  description = "Archivo local con la clave privada para SSH"
  value       = local_file.private_key_pem.filename
}
