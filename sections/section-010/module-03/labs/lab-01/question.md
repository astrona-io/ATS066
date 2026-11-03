# Question

Solve this question on: `terminal`

The platform team made the namespace `hold` by hand. The Deployment `scout` and the ConfigMap `scout-settings` were created with `kubectl create`, so no file describes them and no tool owns their fields. The team wants the release pipeline to own them.

1. Write one manifest file that declares the ConfigMap `scout-settings` with the key `mode` set to `careful`, and the Deployment `scout` with two replicas, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, the label `app: scout` and the selector `app: scout`.

2. In the Deployment, add an environment variable `MODE` for the `scout` container that reads the key `mode` of the ConfigMap `scout-settings` by reference. Do not write a literal value.

3. Apply the file with server-side apply and the field manager name `release-pipeline`. The apply must take over the fields that were set by the earlier commands.

4. Wait until both replicas are available.

Run a server-side dry run first. `kubectl` already points at the cluster as the cluster administrator.
