# Question

Solve this question on: `terminal`

The namespace `launch` runs the Deployment `scout-blue` (two replicas, pod label `version: blue`). The Service `scout` selects `app: scout` and `version: blue`. Release the green version with a blue-green switch.

1. Create a Deployment `scout-green` in `launch` with two replicas, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, the pod labels `app: scout` and `version: green`, and a selector that matches both labels. Set the environment variable `PODINFO_UI_MESSAGE` to `green release`. Add a readiness probe: an HTTP GET on `/readyz` of the port `http` (9898).

2. Wait until both green pods are available. Then change the Service `scout` so that its selector is `app: scout` and `version: green`.

3. Keep the blue version for a fast rollback, but reduce `scout-blue` to one replica. Do not delete it.

Do not change the Service ports. `kubectl` already points at the cluster as the cluster administrator.
