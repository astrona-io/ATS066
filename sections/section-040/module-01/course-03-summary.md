---
draft: true
exam_objectives:
- CI and CD
---
# Summary

A pipeline is an automated path from a source change to a running service. Its job is to turn a commit into evidence: which checks ran, what they found and which artifact came out.

Continuous integration merges changes often and checks every change automatically. A check communicates only through its exit code, so a failure must exit with a non-zero code. A passing check proves only what it looks at. A server-side dry run proves that the API server would accept an object. It does not prove that the image is safe or that the application works, and rules such as "no `latest` tag" must be written as checks.

Continuous delivery keeps every checked change ready to deploy and leaves the release decision to a person or an approval. Continuous deployment deploys every checked change automatically. A path with a manual gate is continuous delivery.

A release is identified by an immutable digest and not by a tag. A tag can be moved to another image, and a digest is computed from the content. A release record that holds the version, the digest, the source revision and the approver, checked against the digest that the pods report, is the evidence that the right artifact runs.

Key facts:

- Exit code 0 means pass and any other code means fail.
- `kubectl apply --dry-run=server` runs the real admission path and stores nothing.
- The pod status field `imageID` shows the digest that the runtime pulled.
- The annotation `kubernetes.io/change-cause` appears in the rollout history.

<!-- astrona:playground:destroy -->
