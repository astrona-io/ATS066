---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Drift, State And Reconciliation

This module explains what OpenTofu remembers, what happens when someone changes a managed object by hand and how an existing object becomes managed. It ends with a question that the exam asks often: when does infrastructure as code count as GitOps, and when is it only automation that runs once?

You declare a namespace and a Deployment, change one of them behind the tool, and find the difference with a plan. Then you attach a hand-made ConfigMap to the files with an import block.

## Learning Goals

- Explain what the state file contains, which component writes it and why it needs protection and locking.
- Define drift and detect it with `tofu plan`, `tofu plan -refresh-only` and the plan exit code.
- Decide between restoring the declared state and accepting the real state.
- Bring an existing object under management with an `import` block without recreating it.
- Compare an IaC workflow with the GitOps principles: declarative, versioned, pulled automatically and continuously reconciled.

## Before You Start

You should be able to write a `resource` block and run `tofu init`, `tofu plan` and `tofu apply`. The hands-on parts use a playground with a kind cluster, `kubectl` and OpenTofu. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads. You create files in a working directory on your machine. OpenTofu creates a namespace and a Deployment from them. Then you change one with `kubectl` and read what OpenTofu reports.

## The Words This Module Uses

- **State**: the file in which OpenTofu stores the identity and the last known values of each managed object.
- **Backend**: the place where the state is stored and, for some backends, locked. The default is a local file.
- **Drift**: a difference between the real object and the last state or the files, caused by a change outside OpenTofu.
- **Refresh**: reading the real objects through the provider and updating the state.
- **Import**: attaching an existing real object to a resource block, so that OpenTofu manages it from then on.
- **Reconciliation**: the repeated act of comparing the real state with the desired state and correcting the difference.

## What You Can Do At The End

You can explain why a lost state file is dangerous and why a state file is sensitive. You can detect drift without changing anything, choose how to resolve it and attach an existing resource to the files without a replacement. You can say, for a given pipeline, whether it only applies once or reconciles continuously, and which GitOps principles it meets.

## Failure Cases This Module Covers

- A `kubectl scale` that changes a managed Deployment, and a plan that wants to undo it.
- A hand-made object that a resource block would try to create again, and fail with an "already exists" error.
- A state file that is lost or edited, so that OpenTofu no longer knows what it owns.
- Two people who apply at the same time without locking.

## Reading Order

1. State, Drift And Detection: what OpenTofu remembers and how it finds a difference.
2. Importing Resources And The GitOps Boundary: attaching existing objects and judging a workflow.
3. Summary

<!-- astrona:playground -->
