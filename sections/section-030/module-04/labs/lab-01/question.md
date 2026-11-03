# Question

Solve this question on: `terminal`

The Deployment `scout` in the namespace `dock` uses the image tag `latest`. The security team wants the API server to refuse mutable image tags in every namespace that carries the label `supply-chain: checked`.

1. Create a ValidatingAdmissionPolicy named `no-latest-tag` for Deployments (`apps/v1`, operations `CREATE` and `UPDATE`). It must be true only when every container image has a digest (`@sha256:`) or a tag that is not `latest`. Give it a clear message and `failurePolicy: Fail`.

2. Create a ValidatingAdmissionPolicyBinding named `no-latest-tag` for that policy. It must deny, and select namespaces by the label `supply-chain: checked`.

3. Label the namespace `dock` with `supply-chain: checked`.

4. Repair `scout`: use the image `ghcr.io/stefanprodan/podinfo:6.15.0` and keep two replicas.

Test the policy with `kubectl create deployment --dry-run=server` before you finish. `kubectl` already points at the cluster as the cluster administrator.
