---
draft: true
exam_objectives:
- CI and CD
---
# Promotion, Delivery And Rollback

A change rarely goes straight to production. It moves through environments such as staging and production, and each step is a promotion. A good promotion carries the same artifact forward with only the configuration changed, checks that the new environment is healthy, and can be undone quickly. This module builds a promotion from `staging` to `production` with `kubectl`, and then breaks it on purpose to practise a rollback.

## Learning Goals

- Explain promotion as moving one artifact through environments, and why the artifact must not be rebuilt.
- Promote a release from staging to production with environment-specific configuration.
- Add a gate that checks health before a promotion is called done.
- Roll back a failed release and verify the result.
- Compare a push pipeline with a pull-based, GitOps style of delivery.

## Before You Start

You should know how to apply a Deployment, read `kubectl rollout status` and use ConfigMaps. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and two environments as namespaces.

| Namespace | Object | Role |
| --- | --- | --- |
| `staging` | `scout` (one replica) | The environment where a release is tried first. |
| `production` | `scout` (two replicas) | The environment that serves users. |

Both Deployments run the podinfo image at version 6.15.0 and read a ConfigMap `scout-settings` with the key `environment`.

## The Words This Module Uses

- **Environment**: a place where the software runs for a purpose, such as staging or production. Here each environment is a namespace.
- **Promotion**: moving a release from one environment to the next.
- **Gate**: an automated or manual check that must pass before the pipeline goes on.
- **Smoke test**: a small test that checks that the main function of a service responds.
- **Rollback**: returning to the previous working release.
- **Push delivery**: a pipeline that applies changes to the cluster from outside.
- **Pull delivery**: an agent inside the cluster that reads the desired state from a repository and applies it.

## What You Can Do At The End

You can promote one release through two environments, prove with a smoke test that it works, undo a release that fails and explain who holds the credentials to change the cluster in a push model and in a pull model.

## Failure Cases This Module Covers

- A promotion that rebuilds the artifact, so production does not run what staging tested.
- A release that reports success while pods are not ready.
- A rollback that restores the image but not the configuration.
- A pipeline credential with write access to every environment.

## Reading Order

1. Promoting One Artifact Through Environments: same image, different configuration.
2. Gates, Rollback And Pull-Based Delivery: checking, undoing and who holds the credentials.
3. Summary

<!-- astrona:playground -->
