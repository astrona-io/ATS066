# Overview: Software Supply Chain Security And Admission Policy (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write small files on your machine, apply them and look at what the cluster does.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The namespace `dock` holds a `scout` Deployment (two replicas) that uses the tag `latest`. No admission policy exists and the namespace has no label.

## Useful commands

```sh
kubectl get pods -A -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u
kubectl -n dock get pods -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].imageID}{"\n"}'
kubectl apply -f policy-no-latest-tag.yaml
kubectl label namespace dock supply-chain=checked
kubectl -n dock create deployment probe-latest --image=ghcr.io/stefanprodan/podinfo:latest --dry-run=server
```

## Practice tasks

- List every image the cluster runs and find the ones that use `latest` or no tag.
- Read the `imageID` of a `scout` pod and write a manifest that pins the image by digest.
- Apply the `no-latest-tag` policy and binding, then test with and without the namespace label.
- Change the binding to `Warn` and `Audit`, send a request and read the warning.
- Break the CEL expression on purpose and see what `failurePolicy: Fail` does.
