---
draft: true
exam_objectives:
- CI and CD
---
# CI/CD And GitOps Together

Many teams first build a pipeline that ends with `kubectl apply` on the cluster. It works, and it also gives the CI system the keys to production. GitOps changes the split of work: the CI pipeline builds, tests and writes the desired state to Git, and an agent inside the cluster pulls that state and applies it. This part explains the split and shows what the CI side changes in the configuration repository.

## Push and pull delivery

In push delivery, the pipeline holds credentials to the cluster and runs the deployment from outside. In pull delivery, the cluster runs an agent such as Argo CD or Flux that watches a Git repository, or an OCI artifact, and applies what it finds. The pipeline needs no cluster credentials. It needs only write access to the repository where the desired state lives.

Pull delivery has three advantages. The credentials stay inside the cluster, so a stolen CI token cannot deploy. The agent compares the live state with Git all the time, so drift is corrected. The state of production is a commit, which gives an audit trail and a rollback by revert.

## What each side does

The CI pipeline owns everything up to the artifact: build, test, scan, push the image and sign it. As its last step it proposes a change to the configuration repository, which is often a separate repository from the application code. The change sets the new image tag or digest. A review or an automatic check approves it, and the merge is the release decision. The GitOps agent owns the cluster side: it detects the new commit, applies it and reports health.

This is why CI and CD are separated in GitOps. They have different triggers, a code change for one and a state change for the other. They need different permissions, and they fail in different ways.

## See the change that CI makes

A CI job changes one line in the configuration repository. Save this as `kustomization.yaml` in a new directory, together with a Deployment file `deployment-scout.yaml` for the `launch` namespace:

<!-- astrona:playground:renew -->

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: launch
resources:
  - deployment-scout.yaml
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.14.0
```

The Deployment file can be the green Deployment from the previous part, saved under this name. The `images` entry overrides the tag at render time. Compare the render with the cluster:

```sh
kubectl diff -k .
```

The diff shows the image tag change for the Deployment. Nothing is applied. A CI job edits the `newTag` value, commits it and opens a pull request. The reviewer reads exactly this diff. After the merge, the agent applies the change.

## Promotion in a GitOps flow

Promotion between environments is also a change in Git. A directory or branch for each environment holds its own settings, and promotion copies the tested image reference from staging to production by pull request. The artifact is the same in both places, and only the settings differ. Rollback is a revert of the commit, and the agent restores the older state.

## Where the pipeline still needs care

The repository now controls production, so access to it needs protection: required reviews, protected branches and signed commits. The pipeline's token should be able to write only to the paths it owns. Secrets still do not belong in the repository. And the agent applies whatever Git contains, which is why checks such as the admission policies and dry runs of earlier modules remain important.

The module now covers the path end to end: the meaning of CI and CD, the pipeline as code, the strategies of release and the split between build and deploy.

## Common pitfalls

> [!WARNING]
> - A CI job with cluster-admin credentials is the weak point of push delivery. Give it only the access it needs, or none.
> - Do not mix application code and environment settings in one commit. Releases and settings change at different speeds.
> - A merge to the configuration repository is a production change. Protect the branch.
> - An agent that applies automatically also applies mistakes. Keep reviews and policy checks in front of it.
