# Question

Solve this question on: `terminal`

A release was pushed to `production` and it failed: the Deployment `scout` there uses an image that does not exist. The namespace `staging` runs the good version. Repair production and then promote release `r2` correctly, from staging to production, with the same artifact.

1. Return the `scout` Deployment in `production` to its previous working revision, using the revision history. Wait until it has two available replicas and no pod tries to use the broken image.

2. Release `r2` to `staging` first: add the label `release: r2` to the pod template of the `scout` Deployment in `staging` and wait for the rollout.

3. Promote it: add the same label to the pod template of `scout` in `production` and wait for the rollout. Do not change the image, the replica counts or the ConfigMaps `scout-settings`. Staging must keep one replica and production two, and each keeps its own `environment` value.

4. Read the image identifier that the production pods report and create a ConfigMap `promotion-record` in `production` with the keys `release` (`r2`), `from` (`staging`) and `image-digest` (the value that starts with `sha256:`).

`kubectl` already points at the cluster as the cluster administrator.
