---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Templating And Packaging: Kustomize And Helm

Production and staging need almost the same manifests with a few different values. Copying the files invites mistakes, so two tools are in common use: Kustomize, which changes plain manifests with overlays, and Helm, which fills in templates from values. Both produce ordinary Kubernetes manifests in the end. This part compares them and shows what each one hands to the cluster.

## Kustomize: plain files and overlays

Kustomize reads a `kustomization.yaml` file that lists resources and changes to apply. It does not use a template language. A base holds the shared manifests, and an overlay for each environment adds a name prefix, a namespace, an image tag or a patch. `kubectl` has Kustomize built in. Save this as `kustomization.yaml` next to `deployment-scout.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment-scout.yaml
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
labels:
  - pairs:
      environment: staging
    includeSelectors: false
```

Render the result without applying it:

```sh
kubectl kustomize .
```

The command prints the Deployment with the label `environment: staging` added. Applying the output is `kubectl apply -k .`. Because the input files are valid manifests on their own, a reviewer can read them without knowing a template language.

## Helm: templates, values and releases

Helm is a package manager for Kubernetes. A chart is a directory with a `Chart.yaml` file, a `values.yaml` file with defaults and a `templates` directory. The templates use the Go template language, for example `replicas: {{ .Values.replicaCount }}`. You change values with a file or with `--set`.

A release is one installed copy of a chart in a cluster. Helm stores the rendered manifests and the values of each release revision in a Secret in the namespace, and that record lets it roll back. The commands that an exam asks about are these:

- `helm template scout ./chart -f values-staging.yaml` renders the manifests and prints them, without a cluster.
- `helm install scout ./chart -n starfleet` creates a release.
- `helm upgrade scout ./chart -f values-production.yaml` changes it.
- `helm rollback scout 1` returns to revision 1.
- `helm list` and `helm history scout` show releases and revisions.

Helm is not installed in the playground, so read these commands as reference. Charts can also be shared through a chart repository or an OCI registry, with a version for each chart.

## Which to choose

Kustomize fits files that your own team owns and changes for a few environments. The files stay plain and the diff stays small. Helm fits software that other teams publish and that many users install with different settings, because a chart can hide a large set of manifests behind a short list of values. Charts also bring risk: a template can contain logic, loops and conditions, and a small value change can render a very different manifest.

The two tools are not exclusive. A GitOps agent can render a Helm chart and then apply a Kustomize patch on top of the result.

## What matters for review

Whatever the tool, the cluster receives rendered manifests. A review that only reads the values or the overlay can miss what the render does. Teams therefore render in the pipeline and run `kubectl diff` or a dry run on the output. This closes the loop of the module: the declared input (values, overlay), the rendered manifests and the live objects can each be compared with the next.

You now have a full path from a file in Git to an object in the cluster, with a record of who owns each field. The summary collects the main points.

## Common pitfalls

> [!WARNING]
> - Do not review only `values.yaml`. Render the chart and read the result.
> - The older Kustomize field `commonLabels` also changes selectors. Changing it on a live Deployment fails because the selector is immutable. The `labels` field with `includeSelectors: false` avoids that.
> - Pin chart versions. A chart without a version can change underneath a release.
> - Do not store Secret values in `values.yaml` in Git.
