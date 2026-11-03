---
draft: true
exam_objectives:
- CI and CD
---
# CI/CD Concepts, Pipelines And Deployment Strategies

Continuous integration and continuous delivery (CI/CD) turn a commit into a running release by a fixed, automated path. This module explains the terms an exam asks about, shows a pipeline step as a Kubernetes Job with an exit code, compares the four common deployment strategies with a blue-green switch you perform yourself, and explains why GitOps separates the build from the deployment.

## Learning Goals

- Define continuous integration, continuous delivery and continuous deployment and tell them apart.
- Describe the stages of a pipeline and what a pipeline file contains.
- Run a pipeline step as a Job and read its exit code.
- Compare recreate, rolling, blue-green and canary deployments by risk, cost and rollback speed.
- Explain how a CI pipeline and a GitOps agent share the work.

## Before You Start

You should know how to apply a Deployment and a Service and how to read `kubectl get`. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35.

| Namespace | Object | Role |
| --- | --- | --- |
| `launch` | `scout-blue` (two replicas) | The version that serves users now. |
| `launch` | `scout` Service | Sends requests to pods with the label `version: blue`. |

## The Words This Module Uses

- **Continuous integration (CI)**: merging changes into the main branch often, with an automated build and test on each merge.
- **Continuous delivery**: every change that passes the pipeline is ready to release, and a person decides when.
- **Continuous deployment**: every change that passes the pipeline is released to production with no manual step.
- **Pipeline**: the automated sequence of stages that moves a change towards production.
- **Artifact**: the output of a build, such as a container image.
- **Deployment strategy**: the method used to replace the running version with a new one.

## What You Can Do At The End

You can say which of the three terms describes a given pipeline, read a pipeline file, switch traffic from one version to another with a Service selector and keep the old version ready for rollback, and place a CI pipeline and a GitOps agent on either side of a configuration repository.

## Failure Cases This Module Covers

- A pipeline step that fails and stops the line, and one that fails silently.
- A blue-green switch to a version that is not yet ready.
- A canary whose traffic share is not what the replica counts suggest.
- A CI pipeline that holds production credentials it does not need.

## Reading Order

1. Continuous Integration, Delivery And Deployment
2. Pipelines As Code
3. Deployment Strategies
4. CI/CD And GitOps Together
5. Summary

<!-- astrona:playground -->
