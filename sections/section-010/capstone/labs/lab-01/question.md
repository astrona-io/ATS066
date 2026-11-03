# Question

Solve this question on: `terminal`

The `scout` service in the namespace `outpost` reads its message from the plain ConfigMap `scout-settings`. The team must ship a new message, `scout v2`, as a reviewed change. Today a change to that ConfigMap would not start a rollout, and the Deployment has a risky update strategy and no readiness probe. Deliver the change so that it reaches every pod without losing capacity, and leave proof of what you did.

The Secret `scout-key` already exists in `outpost` with the key `api-key`. It must stay out of your files and out of any ConfigMap.

1. Create a Kustomize base with the Deployment `scout`, the Service `scout` and a `configMapGenerator` named `scout-settings` with the literal `message=scout v2`. Keep the selector `app: scout`, the container name `scout`, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, the port named `http` (9898) and the service account `scout`. The container takes `PODINFO_UI_MESSAGE` from the key `message` of the ConfigMap and `SCOUT_API_KEY` from the key `api-key` of the Secret `scout-key`, both by reference. Add a readiness probe on `/readyz`.

2. Create an overlay for the namespace `outpost`: three replicas, the label `environment: outpost` on every object without changing a selector, and a patch that sets `maxSurge: 1`, `maxUnavailable: 0`, `minReadySeconds` of at least 10 and `progressDeadlineSeconds` between 30 and 120 (and above `minReadySeconds`).

3. Run `kubectl diff -k` on the overlay, then apply it with `kubectl apply -k` and wait for the rollout to finish.

4. Delete the old ConfigMap `scout-settings` that has the fixed name. Exactly one ConfigMap named `scout-settings-<hash>` must remain.

5. Create the ConfigMap `release-evidence` in `outpost` with these keys: `config-map` (the live generated ConfigMap name), `revision` (the live value of the annotation `deployment.kubernetes.io/revision` on `scout`), `observed-at` (the current time in UTC, like `2026-11-03T10:15:00Z`) and `replicas` (`3`).

`kubectl` already points at the cluster as the cluster administrator. Do not delete the Secret and do not put its value in any file or ConfigMap.
