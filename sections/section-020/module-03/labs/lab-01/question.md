# Question

Solve this question on: `terminal`

The platform team labels every workload with the standard label `app.kubernetes.io/name`. The Deployment `relay` in `yard` still selects on the old label `app: relay`. A teammate tried to change the selector with `kubectl patch` and the request was refused.

1. Replace the Deployment `relay` so that its selector and its pod template use only the label `app.kubernetes.io/name: relay`. Keep two replicas, the image `ghcr.io/stefanprodan/podinfo:6.15.0` and the Deployment label `owner: platform`.

2. Update the Service `relay` so that it selects the same label and has two ready endpoints.

3. Make sure that no pod with the old label `app: relay` is left.

Use `kubectl get ... -o yaml` to read the current objects before you delete anything. `kubectl` already points at the cluster as the cluster administrator.
