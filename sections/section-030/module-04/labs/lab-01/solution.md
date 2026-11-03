# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-04/labs/lab-01
```

## Step 1: Write the policy and the binding

Save this as `policy-no-latest-tag.yaml`:

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

The expression is true for a container when its image has a digest, or has a colon and does not end in `:latest`. The method `all` requires this for every container. Apply it:

```sh
kubectl apply -f policy-no-latest-tag.yaml
```

Run `astrona submit`. The policy check passes. The others fail.

## Step 2: Select the namespace

The binding selects by label, so the policy still ignores `dock`. Label it:

```sh
kubectl label namespace dock supply-chain=checked
```

## Step 3: Test the policy

A server-side dry run sends a request through admission and stores nothing. This request must fail:

```sh
kubectl -n dock create deployment gate-check --image=ghcr.io/stefanprodan/podinfo:latest --dry-run=server
```

The API server refuses it and prints the message of the policy. If it is accepted, wait a few seconds and run it again, because the policy takes a short time to take effect. This request must succeed:

```sh
kubectl -n dock create deployment gate-check --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
```

Run `astrona submit`. The namespace check and the policy test pass.

## Step 4: Repair scout

The existing Deployment still has the old tag, and the policy now rejects any update that keeps it. Change the image:

```sh
kubectl -n dock set image deployment/scout scout=ghcr.io/stefanprodan/podinfo:6.15.0
kubectl -n dock rollout status deployment/scout --timeout=240s
```

The update passes the policy because the new tag is not `latest`. Run `astrona submit`. All four checks pass.
