---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Mutable And Immutable Infrastructure

Once a resource is running, there are two ways to change it. You can log in and change it, or you can build a new one and remove the old one. The first way is called mutable infrastructure and the second immutable infrastructure. The choice decides whether the running system still matches its code after a year of changes. This part shows both in a cluster.

## Mutable infrastructure

In a mutable setup a long-lived server receives updates in place: a package upgrade, a configuration edit over SSH, a hot fix. Each change is small and quick. The cost shows up later. Two servers built from the same code end up with different contents, and nobody can say which change is on which server. This difference between code and reality is configuration drift.

## Immutable infrastructure

In an immutable setup nothing is changed after it starts. To change a resource you build a new version from code, start it, move traffic to it and remove the old one. The code is the only place where a change can be made, so the running system always matches the code. A container follows this model by design: the image holds the software, and a pod is replaced and not repaired.

## Watch a hand change disappear

Add a file inside a running container, as an administrator might do for a quick fix:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/probe -- sh -c 'touch /tmp/hand-fix && ls /tmp'
```

The listing shows `hand-fix`. Now find the pod, delete it and read the replacement:

```sh
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet delete pod -l app=probe
kubectl -n starfleet rollout status deployment/probe
kubectl -n starfleet exec deploy/probe -- ls /tmp
```

The new pod has no `hand-fix` file. The Deployment controller created a new pod from the pod template, and the container started from the image. The hand change lived only in the old container.

## Immutable fields in the API

Kubernetes applies the same idea to some fields of its objects. The label selector of a Deployment cannot change after creation. Try it:

```sh
kubectl -n starfleet patch deployment probe --type=json \
  -p='[{"op":"replace","path":"/spec/selector/matchLabels/app","value":"probe-v2"}]'
```

The API server rejects the request and says that the field is immutable. A Deployment must keep its selector because the selector decides which ReplicaSets and pods belong to it. To use a different selector you create a new Deployment. `kubectl replace --force -f deployment-probe.yaml` does this in one command: it deletes the object and creates it again, so the pods are gone for a moment.

Other changes are allowed but still replace running things. If you change the image tag in the pod template of `scout`, the Deployment creates new pods from the new template and removes the old ones. It never changes a running container: it replaces it.

## The same choice in OpenTofu

An OpenTofu plan marks the two cases. A line with `~` is an update in place, and a line with `-/+` and `forces replacement` is a destroy and create. The provider decides for each field. Changing the size of a virtual machine may be in place; changing its image usually forces a replacement. Read the plan before you apply, because a replacement of a database loses its data.

Replacement is safe only when the service can run with two copies for a short time. This is why immutable designs depend on health checks, a load balancer and data that lives outside the replaced resource. The next part shows how Kubernetes goes further: it also lets you describe infrastructure itself as objects.

## Common pitfalls

> [!WARNING]
> - A change made with `kubectl exec` is lost when the pod is replaced. Put the change in the image or the manifest.
> - `kubectl replace --force` deletes the object first. Do not use it on a service that must not stop.
> - An image tag such as `latest` can point to a different image tomorrow. A replacement may then bring a different version than the one you tested.
> - Data in a container file system disappears with the pod. Use a persistent volume for data that must stay.
