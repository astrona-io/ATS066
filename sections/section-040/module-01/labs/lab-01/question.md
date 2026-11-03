# Question

Solve this question on: `terminal`

The pipeline has checked and approved source revision `rev-0042` of `scout`. Release it in a way that anyone can verify later, without changing the image.

1. Add the label `release: rev-0042` to the pod template of the `scout` Deployment in `starfleet`, so that the pods that run this release carry it. Keep the image and the two replicas, and wait until the rollout is complete.

2. Annotate the Deployment `scout` with `kubernetes.io/change-cause` and a text that names `rev-0042`, for example `release 6.15.0 from rev-0042`.

3. Read the image digest that the running `scout` pods report in the field `imageID`. Create a ConfigMap `release-scout` in `starfleet` with the keys `version` (use `6.15.0`), `digest` (the value that starts with `sha256:`), `source-revision` (`rev-0042`) and `approved-by` (any name).

Take the digest from the pods and do not type it from memory. `kubectl` already points at the cluster as the cluster administrator.
