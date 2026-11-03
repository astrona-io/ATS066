# Overview: CI/CD Concepts, Pipelines And Deployment Strategies (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The namespace `launch` holds `scout-blue` (two replicas) and a Service `scout` that selects `version: blue`.

## Useful commands

```sh
kubectl -n launch get service scout -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n launch get endpointslices -l kubernetes.io/service-name=scout
kubectl -n launch rollout status deployment/scout-green --timeout=120s
kubectl -n launch get job
kubectl diff -k .
```

## Practice tasks

- Write `ci.sh`, run it on a valid and an invalid Deployment file and watch where it stops.
- Run a Job that exits 0 and a Job that exits 1 and read the conditions.
- Deploy `scout-green`, test one of its pods with a port-forward, then switch the Service selector.
- Roll back by patching the selector to `blue`.
- Remove the `version` label from the Service selector and count how requests spread over both versions.
