resource "kubectl_manifest" "ak_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: akeyless-plugin
YAML
}

resource "kubectl_manifest" "ak_service_account" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: token-request-sa
  namespace: akeyless-plugin
YAML

  depends_on = [
    kubectl_manifest.ak_namespace
  ]
}

resource "kubectl_manifest" "ak_sa_token" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: token-request-secret
  namespace: akeyless-plugin
  annotations:
    kubernetes.io/service-account.name: "token-request-sa"
YAML

  depends_on = [
    kubectl_manifest.ak_namespace,
    kubectl_manifest.ak_service_account
  ]
}

resource "kubectl_manifest" "ak_cluster_role" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tokenrequest
rules:
- apiGroups: ["authentication.k8s.io"]
  resources:
  - "tokenreviews"
  verbs:
  - "create"
  - "get"
- apiGroups: [""]
  resources:
  - "serviceaccounts/token"
  verbs:
  - "create"
  - "get"
YAML

  depends_on = [
    kubectl_manifest.ak_namespace,
    kubectl_manifest.ak_service_account,
    kubectl_manifest.ak_sa_token
  ]
}

resource "kubectl_manifest" "ak_cluster_rolebinding" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tokenrequest
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tokenrequest
subjects:
- kind: ServiceAccount
  name: token-request-sa
  namespace: akeyless-plugin
YAML

  depends_on = [
    kubectl_manifest.ak_namespace,
    kubectl_manifest.ak_service_account,
    kubectl_manifest.ak_sa_token,
    kubectl_manifest.ak_cluster_role
  ]
}