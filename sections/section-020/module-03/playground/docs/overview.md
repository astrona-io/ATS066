# Overview: Infrastructure As Code Concepts, Immutability And Safe Change (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads run: `scout` (two replicas), `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`. No OpenTofu file exists; you install OpenTofu on your machine.

## Useful commands

```sh
tofu init && tofu apply -auto-approve
kubectl -n starfleet exec deploy/probe -- ls /tmp
kubectl apply -f crd-bays.yaml
kubectl -n starfleet get bays
tofu plan -out=review.tfplan && tofu show review.tfplan
```

## Practice tasks

- Apply a `terraform_data` configuration twice and read the second plan.
- Add a file with `kubectl exec`, delete the pod and look for the file.
- Try to patch the selector of `probe` and read the error.
- Define the `Bay` custom resource, create an object and set an invalid `size`.
- Save a plan with `tofu plan -out`, show it as JSON and search the state for a sensitive value.
