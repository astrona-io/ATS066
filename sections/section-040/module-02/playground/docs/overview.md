# Overview: Promotion Delivery And Rollback (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You promote a release from `staging` to `production`, break a release on purpose and roll it back.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- Two environments as namespaces, each with a ConfigMap `scout-settings` and a `scout` Deployment on the same image.

| Namespace | Object | What it is |
| --- | --- | --- |
| `staging` | `scout` | podinfo, one replica |
| `production` | `scout` | podinfo, two replicas |

## Useful commands

```sh
kubectl -n staging rollout status deployment/scout --timeout=120s
kubectl -n staging run smoke --rm -i --restart=Never --image=curlimages/curl:8.22.0 -- curl -fsS http://scout/healthz
kubectl -n production rollout history deployment/scout
kubectl -n production rollout undo deployment/scout
kubectl -n production get pods -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
```

## Practice tasks

- Release a change to staging, run a smoke test and then promote it.
- Compare the image identifiers of both environments after a promotion.
- Push an image that does not exist and watch the rollout gate fail.
- Roll back with `kubectl rollout undo` and read the history.
- Change a ConfigMap together with an image and decide what the rollback restores.
