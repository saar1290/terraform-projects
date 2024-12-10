resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-basic"
  create_namespace = true
  timeout          = 1000
  values           = [file("${path.module}/values.yaml")]

  set {
    name  = "controller.replicaCount"
    value = 3
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.loadBalancerIP
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
    value = var.loadBalancerSubnetName
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
}

resource "time_sleep" "assign_ingress_ip" {
  depends_on = [
    helm_release.ingress_nginx
  ]
  create_duration = "10s"

  triggers = {
    release_status = helm_release.ingress_nginx.status
  }
}

data "kubernetes_service_v1" "ingress_svc" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-basic"
  }

  depends_on = [
    helm_release.ingress_nginx,
    time_sleep.assign_ingress_ip
  ]
}