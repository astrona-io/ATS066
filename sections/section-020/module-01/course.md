---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Declarations, Plans And Resource Lifecycle

This module explains how infrastructure as code (IaC) turns a text file into real resources. You declare a namespace, a ConfigMap and a Deployment with OpenTofu, read the plan before it changes anything, apply it and see what OpenTofu does when a change cannot be made in place.

Infrastructure as code means that the desired state of infrastructure is written in files that a tool reads. The tool compares the files with the real resources and creates, changes or deletes resources until both match. OpenTofu is an open source tool that does this. In this module its target is the Kubernetes API, so every resource it manages is an object that you can also read with `kubectl`.

## Learning Goals

- Explain what a provider is and which component talks to the Kubernetes API.
- Write `terraform`, `provider` and `resource` blocks and run `tofu init`, `tofu plan` and `tofu apply`.
- Distinguish infrastructure declarations from application configuration.
- Read a plan: the symbols for create, update in place, destroy and replace, and the text that names the reason for a replacement.
- Save a plan to a file and apply exactly that plan.
- Explain what `lifecycle` rules such as `prevent_destroy` change and what they do not protect.

## Before You Start

You should know what a namespace, a ConfigMap and a Deployment are, and how to run `kubectl get`. The hands-on parts use a playground with a kind cluster, `kubectl` and OpenTofu (the `tofu` command). Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster, which is a Kubernetes cluster that runs inside one container on your machine, with Kubernetes 1.35. It contains the example application of this course, the Starfleet. You create a new namespace named `hangar` with OpenTofu next to it.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | Existing workloads that OpenTofu does not manage. |
| `outpost` | `drifter` | A client in another namespace. |
| `hangar` | created by you | The namespace, ConfigMap and Deployment that you declare in `.tf` files. |

OpenTofu reads the files in a working directory on your machine, not in the cluster. It needs a kubeconfig, which is the file that tells a client which cluster and credentials to use. Set `KUBE_CONFIG_PATH` to the same file that `kubectl` uses before you run `tofu`.

## The Words This Module Uses

- **Provider**: a plugin that OpenTofu downloads and that calls one API. The `hashicorp/kubernetes` provider calls the Kubernetes API.
- **Resource block**: the part of a `.tf` file that declares one real object, such as `kubernetes_namespace_v1`.
- **State**: a file in which OpenTofu records which real object belongs to each resource block.
- **Plan**: the list of actions OpenTofu would take to make the real objects match the files.
- **Apply**: the step that carries out a plan.
- **Replacement**: a change that destroys an object and creates a new one, because a field cannot be edited in place.
- **Lifecycle rule**: a setting inside a resource block that changes how OpenTofu treats that resource.

## What You Can Do At The End

You can write the files for a small environment, run the plan and say in plain words what each line of it will do. You can tell a safe in-place update from a replacement before you apply. You can save a plan so that the apply step runs exactly what a reviewer approved, and you can stop OpenTofu from deleting a resource by mistake.

## Failure Cases This Module Covers

- A provider block with no kubeconfig, so `tofu plan` cannot reach the cluster.
- A field change that forces a replacement and so deletes an object and everything inside it.
- A plan that was reviewed and then applied after the files changed again.
- A `prevent_destroy` rule that blocks a plan, and what to do about it.

## Reading Order

1. Declaring Resources With OpenTofu: providers, resources and the first apply.
2. Reading Plans, Replacement And Lifecycle Rules: what a plan says and how to apply it safely.
3. Summary

<!-- astrona:playground -->
