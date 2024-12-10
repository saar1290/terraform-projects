resource "kubectl_manifest" "atlantis_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: atlantis-rbac
YAML
}

resource "kubectl_manifest" "atlantis_service_account" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: atlantis-rbac
  namespace: atlantis-rbac
YAML

  depends_on = [
    kubectl_manifest.atlantis_namespace
  ]
}

resource "kubectl_manifest" "atlantis_sa_token" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: atlantis-rbac
  namespace: atlantis-rbac
  annotations:
    kubernetes.io/service-account.name: "atlantis-rbac"
YAML

  depends_on = [
    kubectl_manifest.atlantis_namespace,
    kubectl_manifest.atlantis_service_account
  ]
}

resource "kubectl_manifest" "atlantis_cluster_rolebinding" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: atlantis-cluster-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: atlantis-rbac
  namespace: atlantis-rbac
YAML

  depends_on = [
    kubectl_manifest.atlantis_namespace,
    kubectl_manifest.atlantis_service_account,
    kubectl_manifest.atlantis_sa_token
  ]
}
