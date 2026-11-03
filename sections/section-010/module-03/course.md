---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Declarative Configuration, Idempotence And Field Ownership

Configuration as Code (CaC) means that the settings of a system live in files that a tool reads, instead of in commands that a person types. This module explains why Kubernetes works best with files that describe the end state, why running the same file twice must be safe, and how the API server records which tool owns which field of an object. It also compares the two most common ways to produce those files, Kustomize and Helm.

## Learning Goals

- Explain the difference between an imperative command and a declarative file, and why idempotence matters.
- Keep configuration files in Git and check a file against the live cluster with `kubectl diff`.
- Apply an object with server-side apply, read `managedFields` and resolve a field conflict.
- Compare Kustomize overlays with Helm charts and say what each one produces.

## Before You Start

You should know what a namespace, a Deployment and a ConfigMap are, and how to run `kubectl get` and `kubectl apply`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` | The workloads whose configuration you manage. |
| `outpost` | `drifter` | A workload in another namespace. |

You write small files on your machine and apply them with `kubectl`. You also need `git` for one hands-on step.

## The Words This Module Uses

- **Imperative**: a command that says which action to take, such as `kubectl scale`.
- **Declarative**: a file that says which state you want, such as a manifest with `replicas: 3`.
- **Idempotent**: an operation that gives the same result when you run it once or many times.
- **Field manager**: the name that the API server records for the tool that last wrote a field.
- **Server-side apply**: an apply in which the API server merges the file and tracks field ownership.

## What You Can Do At The End

You can turn a hand-made object into a file, prove with `kubectl diff` that the file and the cluster agree, take over the fields of a hand-made object with server-side apply and explain when to choose a Helm chart instead of a Kustomize overlay.

## Failure Cases This Module Covers

- A `kubectl create` that fails the second time because the object already exists.
- A hand change with `kubectl scale` that a later apply silently undoes, or refuses to undo.
- A conflict between two tools that write the same field.
- A template that renders a different manifest than the one that was reviewed.

## Reading Order

1. Imperative And Declarative Commands: the same change made two ways.
2. Desired State In Version Control: history, review and `kubectl diff`.
3. Server-Side Apply And Field Ownership: who owns which field.
4. Templating And Packaging: Kustomize and Helm compared.
5. Summary

<!-- astrona:playground -->
