---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Summary

Configuration as Code means that the settings of a system are written as files, kept in version control, reviewed before they change and applied by a tool. The files are the source of truth, and a second step is needed to apply them again and to see when the live system differs. Storing a file once does not manage a system. Configuration as Code differs from Infrastructure as Code in its subject: it describes the settings of software, where Infrastructure as Code describes the systems that the software runs on.

A ConfigMap holds non-confidential settings and a Secret holds confidential values. Base64 in a Secret is an encoding that anyone can reverse, so the value never belongs in a committed file. Git holds the name of the Secret and the key, and a separate path creates the Secret in the cluster.

A change to a ConfigMap does not create a Deployment revision. An environment variable is fixed when the container starts, so only a new pod sees the new value. A mounted file changes after the kubelet syncs, and only a program that reads the file again sees it. A `subPath` mount never updates. To tie a configuration change to a rollout, make the pod template depend on the content: a checksum annotation or a generated ConfigMap name with a content hash. Then the change goes through the strategy, the probes and the history of a normal rollout.

Kustomize builds manifests from a base and overlays, and `kubectl apply -k` applies the result. The overlay holds the small differences of one place. `kubectl diff -k` shows what an apply would change and exits with `1` when it finds a difference. Drift is a hand-made change in the cluster that the files do not declare. An apply returns the declared fields to their values, removes fields that left the files and keeps extras that were never declared. Applying by hand is not continuous reconciliation: nothing watches the cluster between runs.

Key facts:

- `kubectl kustomize` prints the result and `kubectl apply -k` applies it.
- `labels` with `includeSelectors: false` adds labels without touching selectors.
- `behavior: merge` lets an overlay change values of a base generator.
- `kubectl diff` exit codes: `0` no difference, `1` differences, above `1` an error.
- An immutable ConfigMap cannot change; a new value needs a new object.

<!-- astrona:playground:destroy -->
