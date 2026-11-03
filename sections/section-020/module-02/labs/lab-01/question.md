# Question

Solve this question on: `terminal`

During an incident, an engineer created the namespace `hangar`, the ConfigMap `hangar-settings` and the Deployment `beacon` by hand. The Deployment runs five replicas and the ConfigMap says `mode: manual` and `owner: nobody`. The team wants these exact objects managed by OpenTofu. They must not be deleted and created again, because other systems depend on them.

1. In a new, empty directory on your machine, use the provider `hashicorp/kubernetes` with the version constraint `~> 2.35` and point OpenTofu at the cluster with `KUBE_CONFIG_PATH`.

2. Write one resource block for each of the three objects and one `import` block for each. The namespace has the identity `hangar`, and the namespaced objects have the identity `namespace/name`.

3. The files declare this state: every object has the label `managed-by: opentofu`; the ConfigMap holds `mode: active` and `owner: platform`; the Deployment keeps its selector `app: beacon`, its container `beacon` with the image `ghcr.io/stefanprodan/podinfo:6.15.0`, its `envFrom` of `hangar-settings` and the resource request of 10m CPU and 32Mi memory, and it has two replicas.

4. Run `tofu plan` and read it. It must report three objects to import and changes that are updates in place. No object may be replaced. Apply it.

5. Create drift: scale the Deployment by hand with `kubectl -n hangar scale deployment beacon --replicas=4`. Detect it with `tofu plan -detailed-exitcode` and read the exit code. Restore the declared state with `tofu apply`.

6. The end state is the three original objects, labelled and reconciled, with two available `beacon` replicas.

`kubectl` already points at the cluster as the cluster administrator. Do not delete any of the three objects and do not delete the ConfigMap `seed-record` in the namespace `default`.
