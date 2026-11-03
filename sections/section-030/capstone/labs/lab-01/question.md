# Question

Solve this question on: `terminal`

The namespace `bay` was handed to a new team without any platform contract. It holds the Deployment `relay`, which runs as root with a privileged container, and a Secret `relay-token`. Bring the namespace to a safe, supported state, using only what you need.

1. Limit shared capacity. Create a ResourceQuota in `bay` that allows at most 6 pods, 500m of CPU requests and 512Mi of memory requests. Create a LimitRange that gives each container that declares nothing a default CPU request of 50m, a default memory request of 64Mi and a default memory limit of 128Mi.

2. Enforce a security standard. Make `bay` enforce and warn at the Pod Security level `restricted`.

3. Repair `relay` so that its two pods keep running under that standard. Keep the image `ghcr.io/stefanprodan/podinfo:6.15.0` and two replicas. Use a numeric user. Make `relay` read the Secret `relay-token`, key `token`, in an environment variable `RELAY_TOKEN` by reference and never write the value in a file.

4. Create a ServiceAccount `bay-team` that does not mount a token by default. Give it a Role and a RoleBinding in `bay` so that it can create, read and change Deployments and read Pods, with no wildcard. It must not delete Deployments, read Secrets or create RoleBindings, and it must have no access outside `bay`.

5. Record what you set in a ConfigMap `platform-record` in `bay` with the keys `pod-security` (the level that the namespace enforces), `quota-pods` (the pod ceiling of the quota) and `deployer` (the name of the identity).

Check your work with `kubectl auth can-i --as=system:serviceaccount:bay:bay-team`, `kubectl describe resourcequota` and `kubectl apply --dry-run=server`. `kubectl` already points at the cluster as the cluster administrator.
