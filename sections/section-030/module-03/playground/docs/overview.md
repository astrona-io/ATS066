# Overview: DevOps Principles, Feedback And Measurement (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads run: `scout` (two replicas), `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`. No ownership labels or runbook annotations exist yet.

## Useful commands

```sh
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
kubectl -n starfleet rollout history deployment/scout
kubectl -n starfleet get replicasets -l app=scout --show-labels
kubectl get deployments --all-namespaces -l owner=scout-team
kubectl -n starfleet annotate deployment/scout kubernetes.io/change-cause="Describe the change" --overwrite
```

## Practice tasks

- Read the events of the `starfleet` namespace and find the reasons `Scheduled`, `Pulled` and `Started`.
- Change the image tag or an environment variable of `scout` and read the new revision with `kubectl rollout history`.
- Print the ReplicaSets with their revision numbers and creation times, and work out the time between two revisions.
- Label and annotate the three Deployments, then list them with a label selector across all namespaces.
- Write a short blameless review of an imagined failed rollout: timeline, contributing causes, two actions.
