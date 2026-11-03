---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# DevOps Principles, Feedback And Measurement

DevOps is a way of organising software work so that the people who build a service and the people who run it share the goals, the tools and the responsibility. DevSecOps adds security to the same shared work. This module covers the ideas that an exam asks about: the goals of DevOps, feedback loops, the four key delivery metrics, blameless reviews and the metadata that makes ownership visible. You see each idea in cluster objects that you can query.

## Learning Goals

- State the goals of DevOps and DevSecOps and what each of the five CALMS parts means.
- Name the feedback loops of a delivery path and read the signals that Kubernetes gives for each.
- Define the four key delivery metrics and compute two of them from ReplicaSet data.
- Explain a blameless review and what it produces.
- Record ownership with standard labels and annotations and query it with label selectors.

## Before You Start

You should know what a Deployment, a ReplicaSet and a label are, and how to run `kubectl get` and `kubectl annotate`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the Starfleet workloads.

| Namespace | Object | Role |
| --- | --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` | The workloads that produce events, logs and revision history. |
| `outpost` | `drifter` | A workload in another namespace. |

## The Words This Module Uses

- **DevOps**: shared responsibility of development and operations for a service.
- **DevSecOps**: DevOps in which security checks and security ownership are part of the same work.
- **Feedback loop**: the time from a change to a signal that says whether it worked.
- **Lead time for changes**: the time from a commit to running in production.
- **Change failure rate**: the share of changes that cause a failure in production.
- **Blameless review**: a review of an incident that looks for causes in the system and not in a person.

## What You Can Do At The End

You can explain DevOps in precise terms, read the delivery history of a Deployment, compute lead time and deployment frequency from it, and attach owner and runbook data to workloads so that anyone can find who to ask.

## Failure Cases This Module Covers

- A team that measures output, such as the number of tickets, and not the outcome of delivery.
- A deployment history without a recorded reason for each change.
- A workload that fails at night and has no owner label or runbook.
- A review that names a person and teaches the team nothing.

## Reading Order

1. DevOps Goals And Working Agreements
2. Feedback Loops And Signals
3. Measuring Delivery With Four Key Metrics
4. Blameless Reviews, Ownership And Runbooks
5. Summary

<!-- astrona:playground -->
