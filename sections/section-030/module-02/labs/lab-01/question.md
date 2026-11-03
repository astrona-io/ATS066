# Question

Solve this question on: `terminal`

The namespace `dockyard` runs the Deployment `scout` with a root user and a privileged container. The platform team wants the namespace to enforce a security standard, the pods to meet it and the deploying identity to have only the rights that it needs.

1. Label the namespace `dockyard` so that the Pod Security level `restricted` is enforced and warned about.

2. Repair the `scout` Deployment so that its two pods run and meet the `restricted` level. Keep the image `ghcr.io/stefanprodan/podinfo:6.15.0` and two replicas. Use a numeric user, because the image names its user. The pods must run as a non-root user, must not allow privilege escalation, must not be privileged, must drop all capabilities and must use the runtime default seccomp profile.

3. Make `scout` read the Secret `scout-token`, key `token`, in an environment variable `SCOUT_TOKEN` by reference. Never write the token value in a file or a ConfigMap.

4. Create a ServiceAccount `scout-deploy` in `dockyard` that does not mount a token by default. Give it, with a Role and a RoleBinding, the right to get, patch and update only the Deployment named `scout`, and to list and watch Deployments. It must not read Secrets, delete Deployments or create RoleBindings.

Use `kubectl apply --dry-run=server` before you apply your changes. `kubectl` already points at the cluster as the cluster administrator.
