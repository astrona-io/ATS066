# Question

Solve this question on: `terminal`

The team released version 2 of `scout` in the `starfleet` namespace. The release sets the environment variable `PODINFO_UI_MESSAGE` to `scout v2`. The rollout has stalled: the old pods still serve, and the new pods never become ready. The strategy of the Deployment also allows half of the capacity to go missing during an update. Repair the release and make the next one safer. Do not roll back: the release with the message `scout v2` must reach all pods.

1. Find why the new `scout` pods are not ready and correct the pod template. The readiness probe must be an HTTP check on the path `/readyz`. The image stays `ghcr.io/stefanprodan/podinfo:6.15.0`.

2. Set the rolling update strategy so that the update never lowers capacity: `maxUnavailable` is `0` and `maxSurge` is `1`.

3. Make the controller wait and report: `minReadySeconds` is at least `10`, and `progressDeadlineSeconds` is between `30` and `120` and larger than `minReadySeconds`.

4. Finish the rollout. The Deployment must have 3 updated, ready and available replicas, and all 3 running pods must have the message `scout v2`.

5. Record why the Deployment changed: annotate it with `kubernetes.io/change-cause` and a short text of your own.

`kubectl` already points at the cluster as the cluster administrator. Do not delete, scale or replace the Deployment.
