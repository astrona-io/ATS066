# Overview: Declarative Configuration, Idempotence And Field Ownership (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads run: `scout` (two replicas), `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`. No declared file exists for them on your machine.

## Useful commands

```sh
kubectl apply -f configmap-crew-notes.yaml
kubectl diff -f deployment-scout.yaml; echo $?
kubectl apply --server-side --field-manager=release-pipeline -f deployment-scout.yaml
kubectl -n starfleet get deployment scout --show-managed-fields -o yaml
kubectl kustomize .
```

## Practice tasks

- Create a ConfigMap with `kubectl create` twice and read the error, then declare it as a file and apply it twice.
- Scale `scout` by hand, then apply a file that says two replicas and see the result.
- Run `kubectl diff -f` before and after a change and read the exit code.
- Apply with `--server-side` under two different field manager names and trigger a conflict.
- Render a Kustomize overlay with `kubectl kustomize .` and compare it with the file.
