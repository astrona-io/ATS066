# Overview: Rolling Updates And Availability (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change a Deployment, watch the rollout, break it, repair it, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, four replicas, readiness probe on `/readyz`, default rolling update strategy |
  | `starfleet` | `probe` | go-httpbin, one replica |
  | `starfleet` | `shuttle` | curl client, one replica |
  | `outpost` | `drifter` | curl client in another namespace |

- Every Deployment has one ReplicaSet and no rollout history beyond the first revision.

## Useful commands

```sh
kubectl -n starfleet get replicasets -l app=scout
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet rollout history deployment/scout
kubectl -n starfleet describe pod -l app=scout
kubectl -n starfleet get deployment scout -o jsonpath='{.status.conditions}'
```

## Practice tasks

- Change the environment variable `PODINFO_UI_MESSAGE` with `kubectl set env` and run `kubectl get pods -l app=scout -w` in a second terminal. Count how many pods exist at the highest point and how many are ready at the lowest point.
- Set `maxSurge: 2` and `maxUnavailable: 0` and repeat. Write down the numbers you predicted before you ran it.
- Scale `scout` to three replicas and calculate the surge and unavailable numbers for the 25 percent default.
- Point the readiness probe at `/missing` and find the failing probe in the events of the new pod. Set `progressDeadlineSeconds: 60` and find the `ProgressDeadlineExceeded` condition.
- Release an image tag that does not exist and name the pod state that you see. Roll back and check that the strategy fields stayed.
- Set `revisionHistoryLimit: 1`, make three template changes and try `kubectl rollout undo --to-revision=1`.
