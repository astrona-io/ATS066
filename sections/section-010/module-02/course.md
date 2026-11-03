---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Configuration As Versioned Input

This module explains how application settings become reviewed, versioned files and how a change in those files reaches running pods. You declare settings in a ConfigMap, keep a Secret out of the files, see why an edited ConfigMap does not change a running environment variable, build a Kustomize base and overlay, apply it with `kubectl apply -k` and find hand-made changes with `kubectl diff`.

The module follows one question from the file to the pod. What do the files say, which tool turns them into cluster objects, when does a running application notice the change, and how do you find out that the cluster no longer matches the files?

## Learning Goals

- Define Configuration as Code and tell it apart from Infrastructure as Code and from continuous reconciliation.
- Declare settings in a ConfigMap, consume them as environment variables and as files, and keep Secret values out of committed files.
- Explain when a ConfigMap change reaches a running pod for each way of consuming it.
- Make a configuration change start a rollout with a content-based ConfigMap name or a checksum annotation.
- Build a Kustomize base and an overlay, render it with `kubectl kustomize` and apply it with `kubectl apply -k`.
- Find drift with `kubectl diff -k` and restore the declared state, and explain what an apply does not remove.

## Before You Start

You should know what a pod, a namespace and a Deployment are, and how a rolling update replaces pods. The hands-on parts use a playground with a kind cluster and `kubectl`, and you create small files in a working directory on your machine. Kustomize is part of `kubectl`, so you install nothing extra. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35 and the example application of this course, the Starfleet.

| Namespace | Deployment | Image | Role |
| --- | --- | --- | --- |
| `starfleet` | `scout` | podinfo 6.15.0 | A running service with two replicas. |
| `starfleet` | `probe` | go-httpbin 2.25.0 | A second backend. |
| `starfleet` | `shuttle` | curl 8.22.0 | A client pod that sends requests from inside the cluster. |
| `outpost` | `drifter` | curl 8.22.0 | A client in the namespace where you deploy your overlay. |

podinfo shows the text of the environment variable `PODINFO_UI_MESSAGE`, so a changed setting is visible without a new image.

## The Words This Module Uses

- **Configuration as Code**: settings written as files in version control and applied by a tool.
- **ConfigMap**: a namespaced object that stores non-confidential key and value settings.
- **Secret**: a namespaced object for confidential values. Its data is base64 text, not encrypted text.
- **Kustomize**: a tool built into `kubectl` that builds manifests from a base and overlays.
- **Base and overlay**: shared manifests, and a small set of changes for one place on top of them.
- **Generator**: a Kustomize feature that creates a ConfigMap or Secret and adds a content hash to its name.
- **Drift**: a difference between the files and the live objects, caused by a change outside the files.
- **Reconciliation**: comparing the declared state with the live state and applying the difference.

## Failure Cases This Module Covers

The module works through the cases where configuration as code fails in practice, because the exam asks what happens when a step goes wrong.

- A ConfigMap that is edited and applied while the pods keep the old environment variable.
- A file mounted with `subPath` that never receives the new content.
- A Secret committed to Git as base64 text, which reveals the value to every reader of the repository.
- A label added with the deprecated `commonLabels` field, which changes the selector of a Deployment that cannot change.
- A replica count that someone changed by hand during an incident, so that the cluster no longer matches the files.
- A field that someone added by hand and that an apply does not remove.

For each case you learn which component keeps the old value, which command shows it and which change in the files fixes it.

## Commands You Will Use

- `kubectl apply -f` and `kubectl apply -k` to apply a file or a Kustomize directory.
- `kubectl kustomize` to print the manifests that Kustomize builds, before you apply them.
- `kubectl diff -f` and `kubectl diff -k` to show what an apply would change.
- `kubectl get configmap -o yaml` and `kubectl get secret -o jsonpath` to read stored objects.
- `kubectl exec` with `printenv` and `cat` to read a value inside a running pod.
- `kubectl rollout restart`, `status` and `history` to replace pods and follow the result.

## How To Study This Module

Read each part with the playground open. Each part works on its own and gives you the files to save, so you do not need to remember anything from an earlier part. The files that you create in the third part live in a working directory on your machine, and the commands run from that directory. When a result does not look like the text says, read the live object with `kubectl get -o yaml` before you change a file.

The reading skill that the exam tests is to look at a setting and answer three questions. Where is it declared, what applies it, and when does a running pod see a change? Keep these three questions in mind in every part.

The Common pitfalls box at the end of each part lists the mistakes that cost the most time in practice. Technical terms are defined once, at the place where they first appear.

## Reading Order

1. Configuration As Declared Input: what Configuration as Code is, ConfigMap, Secret and secrets in Git.
2. How A Configuration Change Reaches Pods: environment variables, files, restarts, checksums and generated names.
3. Kustomize Overlays, Diff And Drift: base, overlay, `kubectl apply -k` and `kubectl diff -k`.
4. Summary

## What You Can Do At The End

You can write a base and an overlay that produce different settings for two places from one set of files. You can say, for any ConfigMap consumption path, whether a changed value reaches a running pod and how long it takes. You can make a content change start a normal rollout. You can run a diff, read it and decide whether the live change or the file is right. The graded lab at the end of the readings has you build the files, apply them over a hand-made workload and bring the cluster back to the declared state.

<!-- astrona:playground -->
