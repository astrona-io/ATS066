---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Summary

DevOps is a way of working in which developers and operators share responsibility for a service, ship small changes and use feedback to improve them. A platform supports this work by offering shared capabilities as supported services. It does not take over every decision. The application team keeps its code, its settings and its release choices, and the platform team keeps the shared parts, such as namespaces, identities and limits.

In Kubernetes the boundary is written as objects. The API server checks every request against Roles and RoleBindings and answers `Forbidden` when no rule allows it. A good role grants the verbs and resource types that the work needs, in one namespace, and nothing more. The command `kubectl auth can-i` proves the boundary before the access is handed over.

Capacity needs its own boundary. A ResourceQuota limits the total objects and requests in a namespace. A LimitRange fills in default requests and limits and sets minimums and maximums for single containers. Both are enforced by the API server at admission, and the LimitRange runs first so that a default can satisfy a quota. A scale command can succeed while the pods fail later, so the evidence is in the Deployment status and in the `FailedCreate` events.

Feedback makes these boundaries usable. A refusal that names the identity, the verb, the resource and the limit tells the developer what to change or whom to ask. A label such as `owner` tells the person on call who owns a workload. Automation that hides the reason for a failure moves work to the user and does not reduce it.

Key facts:

- RBAC has allow rules only. Access is the union of all rules that match.
- A Role and its RoleBinding apply to one namespace.
- `kubectl auth can-i --as=system:serviceaccount:<namespace>:<name>` tests another identity.
- A quota on requests needs a request in each pod, or a LimitRange default.

<!-- astrona:playground:destroy -->
