terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    akeyless = {
      source = "akeyless-community/akeyless"
    }
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  values           = [file("${path.module}/values.yaml")]
}

data "akeyless_static_secret" "public" {
  path = "/mso/services/cert-manager/subca/${var.public}"
}

data "akeyless_static_secret" "private" {
  path = "/mso/services/cert-manager/subca/${var.private}"
}

resource "kubernetes_secret_v1" "ca_key_pair" {
  metadata {
    name      = "ca-key-pair"
    namespace = "cert-manager"
  }

  data = {
    "tls.crt" = data.akeyless_static_secret.public.value
    "tls.key" = data.akeyless_static_secret.private.value
  }

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: ca-key-pair
YAML

  depends_on = [
    helm_release.cert-manager,
    kubernetes_secret_v1.ca_key_pair
  ]
}