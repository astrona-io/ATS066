# Question

Solve this question on: `terminal`

The `depot` environment started as a namespace and a ConfigMap made by hand. The platform team now wants all of it declared in OpenTofu files: the two existing objects, plus a quota, a Deployment and a Service. The existing objects must be kept, not deleted and created again.

1. In a new, empty directory on your machine, use the provider `hashicorp/kubernetes` with the version constraint `~> 2.35`, and point OpenTofu at the cluster with `KUBE_CONFIG_PATH`.

2. Import the namespace `depot` and the ConfigMap `depot-settings` with `import` blocks. Declare them with the label `managed-by: opentofu`. The ConfigMap now holds `tier: gold`. It held `tier: bronze` before.

3. Declare a ResourceQuota `depot-quota` in `depot` that allows at most `10` pods.

4. Declare a Deployment `relay` in `depot` with two replicas, the selector and pod label `app: relay`, one container `relay` with the image `ghcr.io/stefanprodan/podinfo:6.15.0` and port 9898. The container reads the whole ConfigMap `depot-settings` with `envFrom`. Declare a Service `relay` that selects `app: relay` and sends port 80 to port 9898. Every new object has the label `managed-by: opentofu`.

5. Read the plan. It must show two imports and no `forces replacement`. Apply it.

6. Scale the Deployment by hand to three replicas, detect the drift with `tofu plan -detailed-exitcode` and restore two replicas with `tofu apply`.

`kubectl` already points at the cluster as the cluster administrator. Do not delete the ConfigMap `capstone-seed-record` in the namespace `default`.
