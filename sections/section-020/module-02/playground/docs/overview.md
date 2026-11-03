# Overview: Drift State And Reconciliation (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You declare objects, change the cluster by hand to create drift, detect it with a plan and import existing objects.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads. No OpenTofu file or state exists.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` | podinfo, two replicas, readiness probe on `/readyz` |
| `starfleet` | `probe` | go-httpbin, one replica |
| `starfleet` | `shuttle` | curl client, one replica |
| `outpost` | `drifter` | curl client in another namespace |

## Useful commands

```sh
tofu plan -refresh-only
tofu plan -detailed-exitcode; echo $?
tofu state show kubernetes_config_map_v1.settings
kubectl -n starfleet scale deployment scout --replicas=3
tofu apply -refresh-only
```

## Practice tasks

- Declare a ConfigMap, apply it, then change it with `kubectl edit` and detect the drift with a plan.
- Read the three exit codes of `-detailed-exitcode` after a change, after no change and after an error.
- Write an `import` block for an object that exists and read the plan before you apply.
- Compare `-refresh-only` with a normal plan on a drifted object.
- Remove a resource from the files and read what the plan proposes to do.
