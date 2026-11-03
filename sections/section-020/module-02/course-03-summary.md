---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Summary

OpenTofu keeps a state file that links each resource address to a real object and stores the last known attribute values. The state is what lets the tool update or destroy the right object. It can hold values that are not in the files, so it is sensitive. A local state file serves one person. A team needs a shared backend with locking, so that two applies never write the state together.

Drift is a difference between a real object and the files, caused by a change outside the tool. A plan refreshes the state from the real objects and then compares them with the files, so it reports the drift and proposes to undo it. A refresh-only plan updates the state and leaves the objects alone. The option `-detailed-exitcode` gives exit code 2 for a non-empty plan, which lets a scheduled job detect drift. Resolving drift means choosing a side: restore the declared state with an apply, or edit the files to accept the real value.

An existing object becomes managed through an import block. The block links a real identity to a resource address. It does not copy values into the files, so the plan shows an update when the block and the object differ. The unique identifier of the object proves that the import kept it.

Infrastructure as code and GitOps overlap and are not the same. Declarative files in version control meet two principles. A person or a one-time pipeline that runs an apply is a push model, and drift waits for the next plan. GitOps also needs an agent that pulls an identified version and reconciles continuously. The control path decides, not the name of the tool.

Key facts:

- `tofu state list` shows the addresses that OpenTofu manages.
- `tofu plan -refresh-only` reports drift without proposing changes to the objects.
- Exit codes of `tofu plan -detailed-exitcode`: 0 no changes, 1 error, 2 changes.
- The identity for a namespaced Kubernetes import is `namespace/name`.

<!-- astrona:playground:destroy -->
