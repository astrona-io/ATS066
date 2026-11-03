---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Summary

Infrastructure as code describes the desired infrastructure in files, so that a tool can create and change the real resources and a team can review the change first. OpenTofu reads the files, and a provider turns each resource block into calls to one API. For Kubernetes the provider calls the API server, so the result is the same set of objects that `kubectl` shows.

A declaration states what should exist. Infrastructure declarations cover the things an application runs on, such as namespaces and quotas, while application configuration covers the behavior of one application. The two overlap at objects such as ConfigMaps, so each input needs a named owner.

The workflow has fixed steps. `tofu init` downloads providers, `tofu plan` compares files, state and the real objects, and `tofu apply` carries out the plan. A plan marks each resource as create, update in place, destroy or replace. A replacement happens when the API cannot edit a field, and the words `forces replacement` name the cause. The plan is a proposal made at one moment. A saved plan file lets the apply step run exactly what a reviewer approved.

A lifecycle rule such as `prevent_destroy` stops a plan that would destroy a resource. It lives in the files only, so it does not stop a deletion with `kubectl` and it disappears when the block is removed. `tofu destroy` removes everything in the state, in reverse order of dependency.

Key facts:

- A resource address has the form `type.name`, for example `kubernetes_namespace_v1.hangar`.
- `-/+` means destroy and create, and `# forces replacement` names the field.
- `tofu plan -out=tfplan` followed by `tofu apply tfplan` applies a reviewed plan.
- A plan does not contain a backup of the data in a resource.

<!-- astrona:playground:destroy -->
