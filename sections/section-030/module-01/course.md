---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Shared Ownership, Feedback And Platform Enablement

This module shows how DevOps practices appear as concrete objects in a Kubernetes cluster. DevOps is a way of working in which the people who build software and the people who run it share responsibility for the result. A platform is the set of shared capabilities, such as namespaces, access rules and resource limits, that a platform team offers so that application teams do not build them again.

You build a small platform contract in the `starfleet` namespace: an identity for the application team, a role that lets the team deploy but not administer, and a quota and default limits that protect the cluster. Then you trigger the limits and read the feedback that Kubernetes returns.

## Learning Goals

- Explain DevOps and platform enablement as shared ownership and name what stays with each side.
- Write a ServiceAccount, a Role and a RoleBinding that give a team the access it needs and no more.
- Test access with `kubectl auth can-i` and read a `Forbidden` message.
- Explain what a ResourceQuota and a LimitRange do, and which component enforces them.
- Read the feedback that a rejected change produces and decide who must act on it.

## Before You Start

You should know what a namespace, a pod and a Deployment are and how to run `kubectl get` and `kubectl apply`. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` | The workloads that the application team owns. |
| `outpost` | `drifter` | A workload in another namespace. The application team must not change it. |

In this module you act in two roles. As the platform team you use the cluster administrator identity that `kubectl` already has. As the application team you use `kubectl` with the option `--as`, which makes the API server treat your request as if the named identity sent it.

## The Words This Module Uses

- **DevOps**: working practices in which development and operations share responsibility for a service, ship small changes and use feedback.
- **Platform team**: the team that offers shared capabilities as supported services.
- **ServiceAccount**: an identity for a process or a person's tooling inside one namespace.
- **Role**: a list of allowed actions (verbs) on resource types inside one namespace.
- **RoleBinding**: the object that gives a Role to an identity.
- **ResourceQuota**: a limit on the total amount of resources or objects in a namespace.
- **LimitRange**: default and maximum resource values for each container or pod in a namespace.

## What You Can Do At The End

You can write the access rules for an application team, prove with a command that they allow the right actions and deny the others, and explain a rejection message to a developer. You can set limits that protect shared capacity and defaults that keep deployments working without extra fields.

## Failure Cases This Module Covers

- A role that is too broad, for example one that allows every verb on every resource.
- A role that is too narrow, so a deployment fails with `Forbidden` and the developer has no hint what to ask for.
- A change that exceeds a quota, and the message that tells the developer which quota it hit.
- A pod without resource requests in a namespace that has a quota for requests.

## Reading Order

1. Ownership Boundaries With Namespaces And RBAC: who may do what in a namespace.
2. Supported Limits And Actionable Feedback: quota, defaults and the messages they produce.
3. Summary

<!-- astrona:playground -->
