---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Summary

Configuration as Code replaces typed commands with files that describe the state you want. A declarative file can be applied again and again with the same result, which is idempotence. An imperative command such as `kubectl create` describes an action and fails or repeats when it runs a second time. A file only controls the fields it names, so a hand change to another field stays until someone removes it.

Version control gives the files a history, an author and a review. A commit explains the reason for a change, a pull request gives other people a chance to read it and a revert is a new commit that undoes an earlier one. `kubectl diff` compares a file with the live object and returns exit code 0 when they agree and 1 when they differ, so a pipeline can use it as a check before it applies.

Server-side apply moves the merge logic to the API server. The server records the field manager of every field in `managedFields`. A second manager that changes a field owned by another gets a conflict, and the conflict forces a decision between giving up the field and taking it with `--force-conflicts`. A field left out of a file is not owned by that file, which lets an autoscaler and a pipeline share one Deployment.

Kustomize and Helm both produce plain manifests. Kustomize patches real manifests with overlays and needs no template language. Helm fills templates from values and tracks releases, which suits software that others publish. Teams render the output and review that, because the cluster receives the rendered result and not the input.

Key facts:

- `kubectl apply` twice in a row prints `unchanged` the second time.
- `kubectl apply --server-side --field-manager=<name>` records the manager `<name>`.
- `kubectl diff` exits with 1 when there is a difference.
- `helm template` renders without a cluster, and `helm rollback` returns to an earlier revision.

<!-- astrona:playground:destroy -->
