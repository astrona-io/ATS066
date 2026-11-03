---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Admission Policy With ValidatingAdmissionPolicy

A rule that lives in a document is followed only when people remember it. A rule that the API server enforces is followed every time. Kubernetes can run such rules inside the API server with no extra software, by using a ValidatingAdmissionPolicy. This part writes a rule that rejects images with the tag `latest`, applies it to chosen namespaces and tests it without changing the cluster.

## Where admission fits

A request to the API server passes authentication, authorisation, then admission, and only then is stored. Admission controllers can change the request (mutating) or accept and reject it (validating). A ValidatingAdmissionPolicy is built in from Kubernetes 1.30 and works without a webhook, so there is no extra service to run and no network call. The rule runs inside the API server process.

Two objects work together. The **ValidatingAdmissionPolicy** holds the rule: which resources it matches, and the CEL expressions that must be true. The **ValidatingAdmissionPolicyBinding** switches the policy on: for which namespaces, and what happens when a rule fails. A policy without a binding does nothing.

## Write the rule

In the expression, `object` is the resource in the request. The rule below says that every container image must carry a digest, or a tag that is not `latest`. Save this as `policy-no-latest-tag.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: no-latest-tag
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.template.spec.containers.all(c, c.image.contains('@sha256:') || (c.image.contains(':') && !c.image.endsWith(':latest')))"
      message: "Every container image must use a version tag other than latest, or a digest."
      reason: Invalid
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: no-latest-tag
spec:
  policyName: no-latest-tag
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        supply-chain: checked
```

The expression uses `all`, which is true when its test is true for each container. A reference without any colon has no tag and so is rejected, because the runtime would treat it as `latest`. The rule reads the text of the reference. It does not check that a tag exists in the registry, and an `initContainers` list is not covered. Apply the file:

```sh
kubectl apply -f policy-no-latest-tag.yaml
```

## Test with a server-side dry run

The namespace `dock` has no label yet, so the binding does not select it. Test a request that should be rejected:

```sh
kubectl -n dock create deployment probe-latest --image=ghcr.io/stefanprodan/podinfo:latest --dry-run=server
```

The request is accepted, because the policy does not apply to this namespace. Label the namespace and send the same request again:

```sh
kubectl label namespace dock supply-chain=checked
kubectl -n dock create deployment probe-latest --image=ghcr.io/stefanprodan/podinfo:latest --dry-run=server
```

The API server now refuses the request and prints the message from the policy and the policy name. A tagged image passes:

```sh
kubectl -n dock create deployment probe-tagged --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
```

Dry run is the safe way to test a policy: the request runs through admission and is not stored. A short delay is possible between creating a binding and the first enforcement, so repeat a test that unexpectedly passes.

## Validation actions

The binding decides what a failure does. `Deny` rejects the request. `Warn` accepts it and sends a warning to the client. `Audit` accepts it and records an audit annotation. A safe rollout of a new rule starts with `["Warn", "Audit"]`, reads the results for a while and then changes to `["Deny"]`. The setting `failurePolicy: Fail` means that an error in evaluating the rule, for example a field that is missing, rejects the request, and `Ignore` lets the request through.

## Existing objects

Admission checks run on requests. The existing `scout` Deployment in `dock` keeps running with its `latest` tag. The policy rejects its next update unless the update fixes the image. Existing objects therefore need a separate sweep, which a pipeline can do with the same rule or by listing images as in the first part of this module.

## Other policy engines

Kyverno and Open Policy Agent Gatekeeper do the same job with their own languages and more features. The two things that a ValidatingAdmissionPolicy does not do are mutate requests and check image signatures. A cluster that must require signed images installs a tool such as Kyverno or the Sigstore policy controller.

## Common pitfalls

> [!WARNING]
> - A policy without a binding does nothing. A binding without a matching namespace selector does nothing.
> - A rule written against the wrong path fails every request when `failurePolicy` is `Fail`. Test with a dry run before you bind it widely.
> - Do not start with `Deny` on a policy that matches many namespaces. Start with `Warn` and `Audit`.
> - The rule checks `Deployment` only. A bare Pod, a StatefulSet or a CronJob needs its own rule.
