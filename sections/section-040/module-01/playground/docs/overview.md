# Overview: Build And Release Pipelines (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. You write a check script and a release record in a working directory on your own machine and run them against the cluster.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The Starfleet workloads. There is no CI server. Your machine plays the pipeline.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` | podinfo, two replicas, readiness probe on `/readyz` |
| `starfleet` | `probe` | go-httpbin, one replica |
| `starfleet` | `shuttle` | curl client, one replica |
| `outpost` | `drifter` | curl client in another namespace |

## Useful commands

```sh
chmod +x ci-check.sh
./ci-check.sh scout-release.yaml; echo $?
kubectl apply --dry-run=server -f scout-release.yaml
kubectl -n starfleet get pods -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
kubectl -n starfleet rollout history deployment/scout
```

## Practice tasks

- Write a check that refuses the tag `latest` and test it on a good and a bad file.
- Add a second rule to the check, for example a required `resources.limits` field.
- Find the digest of the running image and write it in a ConfigMap.
- Annotate a Deployment with a change cause and read the history.
- Explain why a passing dry run does not prove that the image is safe.
