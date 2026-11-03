# Question

Solve this question on: `terminal`

The `scout` Deployment in `starfleet` was created by hand during an incident. Nobody wrote it down: it runs five replicas, and its message is set directly in the container environment. The team wants the settings of `scout` to live in reviewed files. Build a Kustomize base and an overlay in a new directory on your machine, apply the overlay and bring the cluster back to what the files declare.

The Secret `scout-token` already exists in `starfleet` with the key `token`. It must stay out of your files.

1. Create a base with the Deployment `scout`, the Service `scout` and a `configMapGenerator` named `scout-config` with the literal `PODINFO_UI_MESSAGE=scout from the base`. The Deployment keeps the selector `app: scout`, the container name `scout`, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, the container port named `http` (9898), the service account `scout` and a readiness probe on `/readyz`. It reads the whole ConfigMap with `envFrom` and takes `SCOUT_TOKEN` from the key `token` of the Secret `scout-token` with `secretKeyRef`.

2. Create an overlay for the namespace `starfleet`: set the replica count of `scout` to `2`, add the label `environment: starfleet` to every object without changing any selector, and merge the literal `PODINFO_UI_MESSAGE=scout from the overlay` into the generator.

3. Run `kubectl diff -k` on the overlay and read the difference, then apply the overlay with `kubectl apply -k`.

4. Make sure that the running pods use the message `scout from the overlay`, and that no setting made by hand overrides it.

5. The end state is two available `scout` replicas that read one generated ConfigMap named `scout-config-<hash>`.

`kubectl` already points at the cluster as the cluster administrator. Do not delete the Secret and do not put its value in any file or ConfigMap.
