# Question

Solve this question on: `terminal`

A release of `relay` failed in `live`: the Deployment there uses an image that does not exist. The namespace `preview` runs the good version. Recover production, promote release `r3` correctly with the same artifact, prove which artifact runs, and give the pipeline an identity that cannot do more than it must.

1. Return the `relay` Deployment in `live` to its previous working revision. Wait until it has two available replicas and no pod tries to use the broken image.

2. Annotate the Deployment `relay` in `live` with `kubernetes.io/change-cause` and a text that names the source revision `rev-0107`.

3. Promote release `r3`: add the label `release: r3` to the pod template of `relay` in `preview`, wait, and then do the same in `live`. Do not change the image, the replica counts (one in `preview`, two in `live`) or the ConfigMaps `relay-settings`.

4. Create a ConfigMap `release-relay` in `live` with the keys `version` (`r3`), `digest` (the `sha256:` value that the live pods report), `source-revision` (`rev-0107`) and `approved-by` (any name).

5. Create a ServiceAccount `relay-pipeline` in `live` that does not mount a token by default. With a Role and a RoleBinding, let it get, patch and update only the Deployment `relay`, and list and watch Deployments and ReplicaSets. It must not read Secrets, delete Deployments, change any other Deployment or touch `preview`.

`kubectl` already points at the cluster as the cluster administrator.
