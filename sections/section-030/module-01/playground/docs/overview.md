# Overview: Shared Ownership Feedback And Platform Enablement (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You act as the platform team with the administrator identity of `kubectl`, and as the application team with `--as`.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads. No identity, Role, quota or LimitRange exists yet.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` | podinfo, two replicas, readiness probe on `/readyz` |
| `starfleet` | `probe` | go-httpbin, one replica |
| `starfleet` | `shuttle` | curl client, one replica |
| `outpost` | `drifter` | curl client in another namespace |

## Useful commands

```sh
kubectl auth can-i get pods -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl -n starfleet describe resourcequota team-quota
kubectl -n starfleet get events --field-selector reason=FailedCreate
kubectl -n starfleet get deployments -L owner
```

## Practice tasks

- Create a ServiceAccount, a Role and a RoleBinding and test five actions with `can-i`.
- Create a Role that is too broad and find what it allows with `can-i --list`.
- Create a quota of six pods, scale `scout` above it and find the event that explains the refusal.
- Remove the LimitRange and apply a pod without requests under a quota on requests.
- Add an `owner` label and list objects with it as a column.
