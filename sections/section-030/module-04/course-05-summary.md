---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Summary

A software supply chain runs from source code through dependencies, a build, an image and a registry to a deployment, and each link can be attacked. Four kinds of evidence defend it, and none replaces another. A vulnerability scan lists known problems at one moment. A software bill of materials lists the components in an artifact. Provenance records how an artifact was built, and a signature proves who published it. A scan result belongs to one image digest and ages as new vulnerabilities appear.

An image reference has a registry, a repository, a tag and optionally a digest. A tag can move to other content, and a missing tag means `latest`. A digest is the hash of the image and names exactly one content, so pinning by digest makes a deployment repeatable. The status of a pod holds the digest that was actually pulled. The pull policy defaults to `Always` for `latest` and `IfNotPresent` otherwise, which means that a fixed tag can still run different content on different nodes.

A ValidatingAdmissionPolicy runs a CEL rule inside the API server with no webhook. The policy holds the rule and the binding turns it on for chosen namespaces with the actions `Deny`, `Warn` or `Audit`. A server-side dry run tests the rule without storing anything. The policy checks new and updated requests, so existing objects need a separate sweep. Image signatures and mutation need a tool such as Kyverno.

Policy as code puts the same rules at several stages: a secret scan on the developer machine, manifest linters in the pull request, an SBOM, a scan and a signature in the build, a dry run before deployment and admission at the cluster. The cluster check is the guarantee, the earlier checks give fast feedback, and clear messages and an exception path keep the rules in use.

Key facts:

- A digest looks like `sha256:` followed by 64 hexadecimal characters.
- `imagePullPolicy` defaults to `Always` for `latest` and `IfNotPresent` otherwise.
- A policy needs a binding to take effect.
- `kubectl apply --dry-run=server` exits with a non-zero code when admission rejects the object.

<!-- astrona:playground:destroy -->
