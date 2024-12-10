terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

resource "kubectl_manifest" "trafic_log" {
  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: log
spec:
  applyOnForward: true
  types:
    - Ingress
    - Egress
  egress:
  - action: Log
  ingress:
  - action: Log
YAML
}

resource "kubectl_manifest" "ingress_default_allow" {
  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: ingress-default-allow
spec:
  selector: projectcalico.org/namespace in {"kube-system", "kube-node-lease", "gatekeeper-system", "istio-system", "tigera-operator", "calico-system", "kube-node-lease"}
  applyOnForward: true
  types:
    - Ingress
    - Egress
  ingress:
  - action: Allow
  egress:
  - action: Allow
YAML

  depends_on = [
    kubectl_manifest.trafic_log
  ]
}

resource "kubectl_manifest" "ingress_default_deny" {
  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: ingress-default-deny
spec:
  selector: projectcalico.org/namespace notin {"kube-system", "kube-node-lease", "gatekeeper-system", "istio-system", "tigera-operator", "calico-system", "kube-node-lease"}
  applyOnForward: true
  types:
    - Ingress
    - Egress
  egress:
  - action: Allow
YAML

  depends_on = [
    kubectl_manifest.trafic_log,
    kubectl_manifest.ingress_default_allow
  ]
}

resource "kubectl_manifest" "allow-ingress-web-ports" {
  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: allow-ingress-and-web-ports
spec:
  selector: projectcalico.org/namespace == "ingress-basic"
  types:
    - Ingress
  applyOnForward: true
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      ports: [80,http,https,443,8443]
YAML

  depends_on = [
    kubectl_manifest.trafic_log,
    kubectl_manifest.ingress_default_allow,
    kubectl_manifest.ingress_default_deny
  ]
}

resource "kubectl_manifest" "allow-cert-manager-ports" {
  yaml_body = <<YAML
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: allow-cert-manager-ports
spec:
  selector: projectcalico.org/namespace == "cert-manager"
  types:
    - Ingress
  applyOnForward: true
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      ports: [9402,443,10250]
YAML

  depends_on = [
    kubectl_manifest.trafic_log,
    kubectl_manifest.ingress_default_allow,
    kubectl_manifest.ingress_default_deny,
    kubectl_manifest.allow-ingress-web-ports
  ]
}