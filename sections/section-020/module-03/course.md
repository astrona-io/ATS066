---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Infrastructure As Code Concepts, Immutability And Safe Change

Infrastructure as Code (IaC) means that servers, networks, clusters and the objects inside them are created from files, not from clicks or typed commands. The earlier modules of this section use OpenTofu on Kubernetes objects. This module steps back to the ideas that every IaC tool shares: declarative and imperative styles, idempotence, mutable and immutable infrastructure, Kubernetes itself as an infrastructure control plane, and the habits that make infrastructure changes safe to review.

## Learning Goals

- Explain declarative and imperative IaC, name common tools and say which style each one uses.
- Show idempotence by applying the same OpenTofu configuration twice.
- Explain mutable and immutable infrastructure and show an immutable field in Kubernetes.
- Describe how a custom resource and a controller turn Kubernetes into an infrastructure control plane.
- Check, plan and review an infrastructure change, and explain where state and secrets are stored.

## Before You Start

You should know what a Kubernetes object is and have used `kubectl apply`. You need OpenTofu installed on your machine for two parts. The playground cluster is reached through your kubeconfig. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` | Workloads that you change and replace. |
| `outpost` | `drifter` | A workload in another namespace. |

The OpenTofu examples use the built-in `terraform_data` resource, so they need no cloud account and no provider download.

## The Words This Module Uses

- **Declarative**: the code states the end result and the tool finds the steps.
- **Imperative**: the code lists the steps in order.
- **Idempotent**: running the code again changes nothing when the result already exists.
- **Mutable infrastructure**: a running resource is changed in place.
- **Immutable infrastructure**: a running resource is never changed; a new one replaces it.
- **Custom resource**: an object of a kind that you add to the Kubernetes API.

## What You Can Do At The End

You can choose between a declarative and a procedural tool for a task, prove that a configuration is idempotent, explain why a Kubernetes change was rejected as immutable, and run format, validation and plan checks on infrastructure code before anyone applies it.

## Failure Cases This Module Covers

- A script that fails when it runs a second time.
- A change made inside a running container that disappears when the pod is replaced.
- A selector that cannot be changed on a live Deployment.
- A secret value that sits in plain text in a state file.

## Reading Order

1. Declarative And Imperative Infrastructure Code
2. Mutable And Immutable Infrastructure
3. Kubernetes As An Infrastructure Control Plane
4. Reviewing, Testing And Securing Infrastructure Changes
5. Summary

<!-- astrona:playground -->
