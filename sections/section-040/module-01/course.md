---
draft: true
exam_objectives:
- CI and CD
---
# Build And Release Pipelines

A pipeline is an automated path that carries a change from a source repository to a running service. Continuous integration (CI) is the first half of that path: every change is merged into the shared code often and is checked automatically. Continuous delivery and continuous deployment (CD) are the second half: they carry a checked artifact towards production.

This module builds a very small pipeline from files and commands, because the ideas matter more than the tool that runs them. You write a check script that refuses unsafe manifests, read what the check proves and what it does not, and then identify a release by an immutable image digest and not by a tag that can move.

## Learning Goals

- Trace a source change through build, checks and artifact publication.
- Explain what continuous integration checks, and what a passing check does not prove.
- Distinguish continuous delivery from continuous deployment.
- Identify a release by an immutable digest and record the evidence for it.

## Before You Start

You should know what a Deployment, a container image and a ConfigMap are, and how to run `kubectl apply` and `kubectl get`. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` | The workloads. You treat `scout` as the application that the pipeline delivers. |
| `outpost` | `drifter` | A workload in another namespace. |

The cluster has no CI server. You play the part of the pipeline by running a script on your machine. A real pipeline runs the same commands on a server after each change.

## The Words This Module Uses

- **Continuous integration**: merging changes into the shared code often and running automated checks on every change.
- **Artifact**: the output of a build that is later deployed, such as a container image.
- **Digest**: a hash of the content of an image. It names exactly one image and never changes.
- **Tag**: a name such as `6.15.0` that points to an image. A tag can be moved to another image.
- **Continuous delivery**: every checked change is ready to deploy, and a person decides when.
- **Continuous deployment**: every checked change is deployed to production automatically.
- **Release**: a named set of an artifact and its configuration that is ready to run.

## What You Can Do At The End

You can write a check that stops a bad manifest before it reaches the cluster, read its exit code, and say which risks it does not cover. You can find the digest of the image that is running, write it in a release record and explain why the digest identifies the release better than the tag does.

## Failure Cases This Module Covers

- A check that passes although the manifest uses a tag that can move.
- A release that cannot be reproduced because it was identified by a tag.
- A pipeline that deploys an artifact that was never checked.
- A "continuous deployment" claim for a path that still has a manual approval.

## Reading Order

1. Source Changes And Build Evidence: what a pipeline checks and records.
2. Delivery, Deployment And Release Identity: how a checked artifact becomes a release.
3. Summary

<!-- astrona:playground -->
