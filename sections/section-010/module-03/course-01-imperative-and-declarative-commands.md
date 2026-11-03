---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Imperative And Declarative Commands

A cluster is changed by sending requests to the API server. You can send those requests as a list of actions, or you can send a description of the state you want. The choice decides whether a change can be repeated, reviewed and undone. This part makes the same change both ways and shows where they differ.

## Imperative commands

An imperative command names an action. `kubectl create`, `kubectl scale`, `kubectl label` and `kubectl set image` are all imperative. Each one tells the API server what to do now, and the result depends on what already exists. Run a create command:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet create configmap crew-notes --from-literal=shift=night
```

The ConfigMap exists now. Run the same command again:

```sh
kubectl -n starfleet create configmap crew-notes --from-literal=shift=night
```

The second run fails with an `AlreadyExists` error. The command described an action, "create", and the action cannot be done twice. A script made of such commands works once. Run it again after a failure half way and it stops at the first object that exists.

## A declarative file

A declarative file describes the object that must exist. The tool decides which action is needed. Delete the ConfigMap and write the same object as a file. Save this as `configmap-crew-notes.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: crew-notes
  namespace: starfleet
data:
  shift: night
```

Remove the hand-made object and apply the file:

```sh
kubectl -n starfleet delete configmap crew-notes
kubectl apply -f configmap-crew-notes.yaml
```

The output says `configmap/crew-notes created`. Run the same apply a second time:

```sh
kubectl apply -f configmap-crew-notes.yaml
```

The output now says `configmap/crew-notes unchanged`. The command succeeded and changed nothing, because the live object already matches the file. This property is idempotence. Change `shift: night` to `shift: day` in the file and apply it again. The output says `configured`, and only that field changes.

## Why idempotence matters

A pipeline fails sometimes: the network drops, a step times out. If the step is idempotent, the fix is to run it again. If it is not, someone must first find out how far it got. Idempotence also lets a controller or a pipeline apply the same files on a schedule, which is how drift is removed.

The Kubernetes API is built for this. An object has a `spec`, the state you want, and a `status`, the state that controllers observe. A controller compares the two and acts until they match. When you write a file you write a `spec`.

## What a file cannot hide

A declarative file does not remove all risk. `kubectl apply` only touches the fields that appear in the file, so a field that someone changed by hand and that the file does not mention stays as it is. Show it with a scale command:

```sh
kubectl -n starfleet scale deployment/scout --replicas=5
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}{"\n"}'
```

The Deployment has five replicas. If you now apply a file that does not contain `replicas`, the count stays at five, and if you apply the original file, which says two, the count goes back to two. The file is the source of truth only for the fields it names.

You now know why a file is safer than a list of commands: it can be run again, read and compared. The next part adds history and review by putting the file in Git.

## Common pitfalls

> [!WARNING]
> - `kubectl create` is not idempotent. Use `kubectl apply` in scripts and pipelines.
> - A hand change with `kubectl scale` or `kubectl edit` is not recorded anywhere. A later apply may undo it without warning.
> - A file that leaves out a field does not reset that field to a default. It only leaves the live value alone.
> - `kubectl delete` followed by `kubectl apply` removes the object for a moment. Do not use it as a way to update a running service.
