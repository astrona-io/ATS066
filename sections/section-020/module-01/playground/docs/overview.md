# Overview: Declarations Plans And Resource Lifecycle (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write OpenTofu files with the `hashicorp/kubernetes` provider in a working directory on your own machine and apply them with `tofu`.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads. No OpenTofu file exists. OpenTofu is not part of the cluster; install it on your machine.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` | podinfo, two replicas, readiness probe on `/readyz` |
| `starfleet` | `probe` | go-httpbin, one replica |
| `starfleet` | `shuttle` | curl client, one replica |
| `outpost` | `drifter` | curl client in another namespace |

## Useful commands

```sh
export KUBE_CONFIG_PATH="$HOME/.kube/config"
tofu init
tofu plan -out=tfplan
tofu apply tfplan
tofu state list
tofu plan -detailed-exitcode; echo $?
```

## Practice tasks

- Declare a namespace and a ConfigMap, read the plan and apply it.
- Change a ConfigMap value and read the plan. Is it an update in place?
- Change an immutable field of a resource and find the plan line that shows a replacement.
- Add `lifecycle { prevent_destroy = true }` and try to remove the resource from the file.
- Save a plan with `-out` and apply the saved file.
