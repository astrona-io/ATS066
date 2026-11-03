---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Summary

Infrastructure as Code describes infrastructure in files that a tool reads. A declarative file states the result and the tool works out the steps. An imperative script lists the steps. OpenTofu, Terraform, CloudFormation, Bicep, Pulumi and Kubernetes manifests are declarative in their model, and Ansible runs ordered tasks that are written to be idempotent. Idempotence means that running the same code again changes nothing when the result already exists, and a second `tofu apply` that reports no changes shows it.

Infrastructure is mutable when running resources are changed in place and immutable when they are replaced from code. Mutable changes drift away from the code over time. Immutable changes keep the code as the only source of change. A container follows the immutable model: a file added with `kubectl exec` disappears when the pod is replaced, and a field such as the Deployment selector cannot be changed at all. An OpenTofu plan marks an update in place with `~` and a replacement with `-/+`.

Kubernetes can describe infrastructure itself. A CustomResourceDefinition adds a new kind with a schema, and the API server validates the objects. A controller reads those objects and makes them real. Without the controller the object is only data. Tools such as Crossplane and Cluster API supply controllers that manage cloud resources and clusters, with the desired state stored in the cluster and corrected all the time.

Safe change follows a fixed order. Format check and validation run first, a plan is saved and reviewed, policy checks read the plan, and the apply of the saved plan runs from a pipeline with limited credentials. The state file holds every attribute, including secrets marked sensitive, so it belongs in an encrypted, locked, access controlled remote backend and never in Git.

Key facts:

- `mkdir -p` and `tofu apply` are idempotent; `mkdir` is not.
- A line with `-/+` and `forces replacement` in a plan destroys and creates the resource.
- `tofu plan -detailed-exitcode` exits with 2 when changes are needed.
- `sensitive = true` hides a value from output but not from the state.

<!-- astrona:playground:destroy -->
