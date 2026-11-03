# Question

Solve this question on: `terminal`

The platform team wants the `hangar` environment to be created from reviewed files and not from commands. Write the OpenTofu files in a new, empty directory on your machine, read the plan, apply it and then change one setting through the files.

1. Use the provider `hashicorp/kubernetes` with the version constraint `~> 2.35`. Point OpenTofu at the cluster with `KUBE_CONFIG_PATH`.

2. Declare a namespace `hangar` with the label `managed-by: opentofu`.

3. Declare a ConfigMap `hangar-settings` in `hangar` with the label `managed-by: opentofu` and the data `mode: standby` and `owner: platform`.

4. Declare a Deployment `beacon` in `hangar` with the label `managed-by: opentofu`. It has two replicas, the selector and pod label `app: beacon`, one container named `beacon` with the image `ghcr.io/stefanprodan/podinfo:6.15.0` and the container port 9898. The container reads the whole ConfigMap `hangar-settings` with `envFrom`. Make the ConfigMap and the Deployment refer to the namespace resource and not to the plain text `hangar`.

5. Run `tofu init`, `tofu plan` and `tofu apply`. Then change `mode` from `standby` to `active` in the file, read the plan and confirm that it is an update in place, and apply it.

6. A running container never sees a changed environment variable. Make sure that both `beacon` pods read `mode=active`.

`kubectl` already points at the cluster as the cluster administrator. Do not create the objects with `kubectl`.
