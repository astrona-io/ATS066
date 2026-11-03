---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Image References, Tags, Digests And Pull Policy

A deployment names an image, and the container runtime downloads whatever that name points to at the moment. If the name can point to different content over time, then a deployment you tested last week can run different software today. This part shows how an image reference is built, why a digest fixes the content, and which rule decides when a node downloads an image again.

## Parts of an image reference

An image reference has up to four parts: the registry host, the repository path, a tag and a digest. In `ghcr.io/stefanprodan/podinfo:6.15.0`, `ghcr.io` is the registry, `stefanprodan/podinfo` is the repository and `6.15.0` is the tag. Without a registry, the runtime assumes Docker Hub. Without a tag it assumes `latest`.

A tag is a name that the publisher sets and may move to another image at any time. A digest is the SHA-256 hash of the image manifest, written `sha256:` followed by 64 hexadecimal characters. A digest names exactly one content. If a single byte changes, the digest changes. A reference such as `ghcr.io/stefanprodan/podinfo@sha256:<DIGEST>` can only ever pull the same image.

## Find the digest of a running image

The container status of a pod records the image content that was pulled. Read it from a `scout` pod:

<!-- astrona:playground:renew -->

```sh
kubectl -n dock get pods -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].imageID}{"\n"}'
```

The value has the form `ghcr.io/stefanprodan/podinfo@sha256:` followed by the digest of the image that the node pulled. Compare it with the image in the pod specification:

```sh
kubectl -n dock get pods -l app=scout -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
```

The specification shows the tag that someone wrote. The status shows what actually ran. With a mutable tag the two can disagree over time, and only the status tells you which content the pod uses.

## Pin by digest

A pipeline resolves the tag to a digest once, at build or release time, and writes the digest into the manifest. Save this as `deployment-scout-pinned.yaml` and replace `<DIGEST>` with the hash from the previous command, without the `sha256:` prefix:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout-pinned
  namespace: dock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout-pinned
  template:
    metadata:
      labels:
        app: scout-pinned
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo@sha256:<DIGEST>
```

Apply it:

```sh
kubectl apply -f deployment-scout-pinned.yaml
```

The pod starts from exactly the content that was tested. A human can no longer tell the version from the reference, so teams often keep the tag too: `podinfo:6.15.0@sha256:<DIGEST>`. The runtime then uses the digest, and the tag is a comment for readers. Tools such as Renovate or Dependabot update the pair in a pull request, which keeps pinning and updating both possible.

## The image pull policy

The field `imagePullPolicy` decides when the node contacts the registry. `IfNotPresent` uses a local copy if the node has one. `Always` checks the registry on every container start and pulls if the digest differs. `Never` uses only a local copy. If you do not set the field, Kubernetes sets `Always` when the tag is `latest` or missing, and `IfNotPresent` otherwise.

The consequence is easy to miss. With a fixed tag and `IfNotPresent`, a node that already has the image never sees a new image pushed under the same tag, while a new node pulls the new one. Two pods of one Deployment can then run different content. A digest removes the problem.

## Registry rules

A pull needs access. Private registries use an image pull secret that the pod references. A team should also limit which registries workloads may use, since an image from an unknown registry has no review at all. That limit is a policy, and the next part writes one.

## Common pitfalls

> [!WARNING]
> - The tag `latest` is only a name. It does not mean the newest image, and it can change under a running Deployment's feet when a pod restarts.
> - A scan result belongs to a digest. After a tag moves, the scan no longer applies.
> - Do not copy a digest from a web page. Resolve it from the registry or from a running pod in your own pipeline.
> - Pinning stops updates. Keep an automated process that proposes new digests.
