---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Rolling Updates And Availability

This module explains how a Deployment replaces running pods when its pod template changes, and how you keep a service available while it does. You change the `scout` Deployment in the `starfleet` namespace, watch the old and new ReplicaSets trade pods, break a rollout on purpose, read the evidence and fix it.

A rolling update is the first place where "the desired state is in a file" meets "the running state is in a cluster". The file says what the new version looks like. The Deployment controller decides how fast and how safely the cluster moves there, and the settings you declare control that speed and that safety.

## Learning Goals

- Name the field changes that create a new Deployment revision and the ones that do not.
- Explain which component creates, scales and removes the ReplicaSets and pods during a rollout.
- Calculate the numbers that `maxSurge` and `maxUnavailable` allow, including percentage rounding.
- Explain how readiness, `minReadySeconds` and `progressDeadlineSeconds` decide whether a rollout moves on, waits or reports failure.
- Diagnose a stalled rollout from the Deployment status, the ReplicaSets, the pod states and the events.
- Roll back to an earlier revision and list what a rollback does not restore.

## Before You Start

You should know what a pod, a namespace and a Deployment are, and how to run `kubectl get` and `kubectl describe`. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster, which is a Kubernetes cluster that runs inside one container on your machine, with Kubernetes 1.35. It contains the example application of this course, the Starfleet.

| Namespace | Deployment | Image | Role |
| --- | --- | --- | --- |
| `starfleet` | `scout` | podinfo 6.15.0 | The service that you update. Four replicas and a readiness probe on `/readyz`. |
| `starfleet` | `probe` | go-httpbin 2.25.0 | A second backend that you leave unchanged. |
| `starfleet` | `shuttle` | curl 8.22.0 | A client pod. You use it to send requests to `scout` from inside the cluster. |
| `outpost` | `drifter` | curl 8.22.0 | A client in another namespace. |

podinfo is a small web application that answers HTTP requests and exposes the paths `/healthz` and `/readyz` for health checks. It shows the text of the environment variable `PODINFO_UI_MESSAGE`, so an environment change gives you a visible difference between two releases without a new image.

## The Words This Module Uses

- **Deployment**: the object that declares a pod template, a replica count and an update strategy.
- **ReplicaSet**: the object that keeps a fixed number of pods for one pod template.
- **Pod template**: the `spec.template` field of a Deployment. A change inside it creates a new revision.
- **Revision**: one numbered version of the pod template, stored as one ReplicaSet.
- **Rolling update**: the strategy that replaces pods in small steps so that the service keeps running.
- **Readiness probe**: a check that decides whether a pod may receive traffic and count as available.
- **Progress deadline**: the time after which the controller reports that a rollout has stopped.
- **Rollback**: a new rollout of an older pod template.

## What You Can Do At The End

You can predict, before you apply a change, how many pods the controller creates and removes in each step. You can turn a vague report such as "the release is stuck" into a named cause from the pod state and the events. You can set a strategy that never lowers capacity and name the cluster capacity it needs. You can restore an earlier template and say which parts of the system the restore did not touch.

The graded lab at the end of the readings gives you a stalled rollout of `scout` to repair while the intended release still goes forward. It tests the strategy, the readiness probe, the timing fields and the revision record together.

## Failure Cases This Module Covers

Each part works through at least one failure, because a rollout is easy when it works and the exam asks what happens when it does not.

- A readiness probe that points at a path the application does not serve. The pod runs, never becomes ready and never replaces an old pod.
- A strategy with `maxUnavailable: 0` on a cluster that has no room for the surge pod. The new pod stays `Pending`.
- An image tag that does not exist. The new pod shows `ErrImagePull` and then `ImagePullBackOff`.
- A percentage strategy on a small Deployment, where rounding gives a different number than the reader expected.
- A rollback that restores the image but not the ConfigMap, the Secret or the data that the new version changed.

For each case you learn which component reports the problem, which `kubectl` command shows it and which field fixes it.

## Commands You Will Use

- `kubectl get replicasets` and `kubectl get pods` to see the objects that a rollout creates.
- `kubectl rollout status`, `kubectl rollout history` and `kubectl rollout undo` to follow, list and reverse a rollout.
- `kubectl set env` and `kubectl patch` to change a pod template or a strategy field.
- `kubectl describe pod` to read probe failures and image pull errors in the events.
- `kubectl get deployment -o jsonpath` to read one field or the status conditions.
- `kubectl exec` with `curl` to send a request to a Service from inside the cluster.

Every command is introduced with the reason you run it, and the text names the component that does the work behind it: the API server, the Deployment controller, the ReplicaSet controller, the scheduler or the kubelet.

## How To Study This Module

Read each part with the playground open. The parts give the commands in the order that makes sense for the text, and each part works on its own. If a command output does not look like the text describes, read the pod events with `kubectl describe` before you change anything. Do not skip the failure steps: the reading skill that the exam tests is to look at a state and name the cause.

Technical terms are defined once, where they first appear in a page. The Common pitfalls box at the end of each part lists the mistakes that cost the most time in practice.

## Reading Order

1. Rolling Updates And Health Gates: what the controller does when a template changes.
2. Calculating Rollout Capacity And Diagnosing Progress: the numbers, the deadline and a stalled rollout.
3. Rollback, History And Verification: undoing a release and proving a release works.
4. Summary

<!-- astrona:playground -->
