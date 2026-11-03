---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Software Supply Chain Security And Admission Policy

A running container is the end of a long chain: source code, dependencies, a build, an image, a registry and a deployment. An attacker who changes any link gets code into production without breaking into the cluster. DevSecOps therefore checks the chain, and not only the running pod. This module explains what each check proves, how an image is named in a way that cannot change, and how the Kubernetes API server can refuse an image that breaks a rule.

## Learning Goals

- Name the links of a software supply chain and the attacks against each one.
- Explain what an SBOM, a vulnerability scan, provenance and an image signature each prove.
- Pin an image by digest and explain the default image pull policy.
- Write a ValidatingAdmissionPolicy with a Common Expression Language (CEL) rule and bind it to namespaces.
- Place lint, scan, sign and admission checks at the right step of a pipeline.

## Before You Start

You should know what a container image, a registry and a Deployment are. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35.

| Namespace | Object | Role |
| --- | --- | --- |
| `dock` | `scout` (two replicas) | A Deployment that uses the mutable tag `latest`. |
| `dock` | label `supply-chain=checked` | The label that a policy binding will select. |

## The Words This Module Uses

- **Software supply chain**: everything that goes into a deployed artifact, from source to registry.
- **SBOM**: a software bill of materials, a list of the components inside an artifact.
- **Digest**: the SHA-256 hash of an image, which names exactly one image content.
- **Provenance**: a signed record of how and where an artifact was built.
- **Admission control**: checks in the API server that accept or reject a request before it is stored.
- **CEL**: Common Expression Language, the small language that policies use for rules.

## What You Can Do At The End

You can list the images a cluster runs, find the digest of a running image, write an admission policy that rejects images with the tag `latest`, test it with a server-side dry run and say where in a pipeline each supply chain check belongs.

## Failure Cases This Module Covers

- A tag that points to a different image tomorrow than today.
- A Deployment that a new policy rejects, and an old Deployment that the policy does not touch until its next update.
- A policy with a rule error that rejects every request.
- A pipeline that scans an image and then deploys a different one.

## Reading Order

1. The Software Supply Chain And Its Attack Points
2. Image References, Tags, Digests And Pull Policy
3. Admission Policy With ValidatingAdmissionPolicy
4. Policy As Code And Pipeline Checks
5. Summary

<!-- astrona:playground -->
