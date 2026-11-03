# Overview: Security Checks In The Delivery Path (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You label the namespace, read the refusals, repair the pod specification and create a deployment identity.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The namespace `dockyard` with an unsafe `scout` Deployment (two replicas, root user, privileged container) and a Secret `scout-token`. No Pod Security label is set.

| Namespace | Object | What it is |
| --- | --- | --- |
| `dockyard` | `scout` | podinfo, two replicas, root user, privileged |
| `dockyard` | `scout-token` | a Secret with the key `token` |

## Useful commands

```sh
kubectl label --dry-run=server --overwrite namespace dockyard pod-security.kubernetes.io/enforce=restricted
kubectl -n dockyard rollout restart deployment/scout
kubectl -n dockyard get events --field-selector reason=FailedCreate
kubectl apply --dry-run=server -f scout-restricted.yaml
kubectl auth can-i get secrets -n dockyard --as=system:serviceaccount:dockyard:scout-deploy
```

## Practice tasks

- Warn first with the label `warn=restricted` and read the warnings.
- Enforce `baseline` and find what `restricted` adds on top of it.
- Repair `scout` with a security context and check it with a server-side dry run.
- Set `runAsNonRoot` without a numeric user and read the failure.
- Create a deployment identity for one Deployment and test six actions with `can-i`.
