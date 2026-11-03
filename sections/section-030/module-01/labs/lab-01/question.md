# Question

Solve this question on: `terminal`

The platform team offers the namespace `starfleet` to the application team that owns `scout`. Build the platform contract for it: an identity with limited access, a ceiling on shared capacity and defaults that keep deployments working.

1. Create a ServiceAccount `scout-team` in `starfleet`.

2. Give it a Role and a RoleBinding in `starfleet` so that it can create, read and change Deployments, read Pods and Services and read pod logs. It must not be able to delete Deployments, read Secrets, create RoleBindings or touch the namespace `outpost`. Do not use a wildcard in any rule.

3. Create a ResourceQuota in `starfleet` that allows at most 6 pods, 500m of CPU requests and 512Mi of memory requests.

4. Create a LimitRange in `starfleet` that gives each container that declares nothing a default CPU request of 50m, a default memory request of 64Mi and a default memory limit of 128Mi.

5. Add the label `owner=scout-team` to the `scout` Deployment so that people know whom to ask. Do not change the number of replicas.

Prove the access rules with `kubectl auth can-i` and the option `--as=system:serviceaccount:starfleet:scout-team`. `kubectl` already points at the cluster as the cluster administrator.
