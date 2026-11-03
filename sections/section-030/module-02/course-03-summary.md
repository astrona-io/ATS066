---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Summary

DevSecOps puts security checks into the same automated path that carries a change to production. The checks run early and often, and each one covers one boundary. No single check, such as an image scan, covers every boundary.

Pod Security Admission is a check inside the API server. Labels on a namespace choose a mode (`enforce`, `warn` or `audit`) and a level (`privileged`, `baseline` or `restricted`). The check applies to new pods, so existing pods keep running, and the first restart after a policy change can fail. A Deployment is accepted, and the failure appears as `FailedCreate` events on its ReplicaSet. A `restricted` pod sets `runAsNonRoot` with a numeric user, disables privilege escalation, drops all capabilities and uses the runtime default seccomp profile.

A server-side dry run with `kubectl apply --dry-run=server` sends a request through authentication, authorisation and admission without storing it. It is a useful check in a pipeline, because it shows a refusal or a warning before the change is made.

The identity that deploys also needs limits. A deployment identity receives only the verbs and objects that its task needs, in one namespace, and `kubectl auth can-i` proves it. A service account that does not need to call the API server has no token mounted. Secrets are base64 encoded and not encrypted by default, so a manifest refers to a Secret by name and key and never holds the value, and an identity without a need to read Secrets cannot read them.

Key facts:

- Namespace label: `pod-security.kubernetes.io/<mode>: <level>`.
- `restricted` needs a security context at the pod and container level together.
- `resourceNames` limits `get`, `patch` and `update` to named objects, and cannot limit `list`.
- `automountServiceAccountToken: false` stops a token from being mounted.

<!-- astrona:playground:destroy -->
