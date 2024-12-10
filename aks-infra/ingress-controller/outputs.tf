output "loadBalancerIP" {
  value = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}