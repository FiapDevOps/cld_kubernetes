output "control-plane_ip-addr" {
  description = "The private IP address assigned to the instances"
    value = aws_instance.kubernetes_controlplane.private_ip
}

output "workers_ip-addrs" {
  description = "The private IP address assigned to each worker node"
    value = aws_instance.kubernetes_workers.*.private_ip
}

output "private_key" {
  value     = tls_private_key.lab_resource_key.private_key_pem
  sensitive = true
}