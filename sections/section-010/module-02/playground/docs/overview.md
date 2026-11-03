# Overview: Configuration As Versioned Input (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them, change them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. Kustomize is part of `kubectl`.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, two replicas, readiness probe on `/readyz` |
  | `starfleet` | `probe` | go-httpbin, one replica |
  | `starfleet` | `shuttle` | curl client, one replica |
  | `outpost` | `drifter` | curl client in another namespace |

- No ConfigMap or Secret beyond the Kubernetes defaults. Create a working directory on your machine for the files you write.

## Useful commands

```sh
kubectl kustomize overlays/outpost
kubectl apply -k overlays/outpost
kubectl diff -k overlays/outpost
kubectl -n outpost get configmaps
kubectl -n outpost exec deploy/scout -- printenv PODINFO_UI_MESSAGE
```

## Practice tasks

- Create a ConfigMap and a Deployment that reads one key as an environment variable and one as a file. Change the ConfigMap and measure how long the file takes to change.
- Mount one key with `subPath` and show that the file never changes.
- Build a base and an overlay for `scout` in `outpost`. Change the overlay message and count the ReplicaSets before and after.
- Scale the Deployment by hand, find the change with `kubectl diff -k` and read its exit code with `echo $?`.
- Add a label by hand with `kubectl label` and decide whether `kubectl apply -k` removes it.
- Add `commonLabels` to a kustomization and see what happens to the selector of an existing Deployment.
