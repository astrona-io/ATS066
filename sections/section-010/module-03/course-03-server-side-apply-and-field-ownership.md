---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Server-Side Apply And Field Ownership

Several tools write to the same object in a real cluster: a person, a pipeline, a horizontal autoscaler, an operator. If each one writes without a rule, the last writer wins and nobody knows why a value changed. Kubernetes solves this with server-side apply, in which the API server records which tool owns which field. This part shows the records and the conflicts they prevent.

## How client-side and server-side apply differ

The classic `kubectl apply` is client-side. `kubectl` reads the live object, reads the last applied file that it stored in an annotation called `kubectl.kubernetes.io/last-applied-configuration`, computes a patch and sends it. All logic sits in the `kubectl` binary.

Server-side apply moves the logic to the API server. You send the whole file with `kubectl apply --server-side`. The API server merges it into the object and, for every field, records the name of the field manager that set it. The record is in `metadata.managedFields`. A field manager is just a string. `kubectl` picks a default, and you can choose your own with `--field-manager`.

## Read who owns what

Apply the Deployment file from the previous part with server-side apply and a clear manager name:

<!-- astrona:playground:renew -->

```sh
kubectl apply --server-side --field-manager=release-pipeline -f deployment-scout.yaml
```

The managed fields are hidden by default. Ask for them:

```sh
kubectl -n starfleet get deployment scout --show-managed-fields -o yaml
```

Look for the `managedFields` list. It has an entry with `manager: release-pipeline` and `operation: Apply`, and its `fieldsV1` map lists the fields that the file set, such as `f:replicas` and `f:image`. Other entries belong to controllers that wrote status.

## A conflict

Now a second writer changes a field that `release-pipeline` owns. Use a command that counts as another manager:

```sh
kubectl -n starfleet scale deployment/scout --replicas=4
```

Scaling writes `spec.replicas` under a different manager name. Because that write is an update and not an apply, the change is allowed, and ownership of `replicas` moves to the new writer. Apply the file again as `release-pipeline`:

```sh
kubectl apply --server-side --field-manager=release-pipeline -f deployment-scout.yaml
```

The API server refuses and reports a conflict that names the other manager and the field `.spec.replicas`. The refusal is the feature. The pipeline cannot overwrite a hand change by accident. You have two honest choices. Remove the field from the file if another tool should own it, or take it back on purpose:

```sh
kubectl apply --server-side --field-manager=release-pipeline --force-conflicts -f deployment-scout.yaml
```

The `--force-conflicts` flag makes the apply win and moves ownership of the field back to `release-pipeline`. Use it when the file is the intended owner, and say so in the commit message.

## When another controller owns a field

A HorizontalPodAutoscaler changes `spec.replicas` of a Deployment on its own. If the file in Git also says `replicas: 2`, every apply fights the autoscaler. The fix is to leave `replicas` out of the file. With server-side apply, a field that the file does not mention is not owned by the file, so the autoscaler keeps it.

The same idea explains how a GitOps agent can run next to other tools. It owns the fields in its files and leaves the others alone.

You can now see ownership instead of guessing it. The last part of this module turns to the question of how the files are produced, because writing every environment by hand does not scale.

## Common pitfalls

> [!WARNING]
> - Do not use `--force-conflicts` to make an error go away. First find out which manager owns the field and why.
> - Mixing client-side and server-side apply on one object can leave ownership records that look odd. Choose one method for each object.
> - A file that lists `replicas` takes ownership of it. Leave it out when an autoscaler manages the count.
> - `managedFields` is not shown unless you pass `--show-managed-fields`.
