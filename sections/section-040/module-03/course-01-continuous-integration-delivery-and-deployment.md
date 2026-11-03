---
draft: true
exam_objectives:
- CI and CD
---
# Continuous Integration, Delivery And Deployment

The abbreviation CI/CD hides three different practices, and an exam often asks which one a team follows. They form a ladder. Each step automates a larger part of the path from a commit to the user. This part defines the three terms, lists the stages of a pipeline and shows a pipeline script that stops on its first failure.

## Continuous integration

Continuous integration means that developers merge their changes into a shared main branch at least daily, and an automated build and test runs on every merge or pull request. The aim is to find conflicts and defects within minutes, while the change is small. A team that integrates once a month meets a large, painful merge. Trunk-based development, with short-lived branches and feature flags for unfinished work, supports CI.

## Continuous delivery

Continuous delivery extends CI so that every change that passes the pipeline produces a release candidate that can be deployed at any time. The pipeline builds the artifact once, tests it, scans it and deploys it to a test environment. A person then presses the button for production, for business reasons or because of a regulation.

## Continuous deployment

Continuous deployment removes the button. Every change that passes all checks goes to production. It needs strong tests, health checks, fast rollback and small changes. It is not "better" than continuous delivery in every case, but it is the logical end of the ladder. The word "CD" can mean either delivery or deployment, so ask which one.

## Stages of a pipeline

A typical pipeline has these stages, in order. Source: a commit or pull request starts the run. Build: compile the code and build the image. Test: run unit tests, then integration tests. Scan: check dependencies, the image and the manifests. Package and publish: push the image to a registry and give it an identity. Deploy: apply the release to an environment. Verify: run smoke tests and health checks. Cheap and fast stages come first so that a failure is reported quickly. The artifact is built once and promoted, so the thing that was tested is the thing that is released.

## A pipeline that stops at the first failure

A pipeline is a script with stages, and each stage reports success or failure through an exit code. Save this as `ci.sh` next to `deployment-scout.yaml` from a Deployment file of your own:

<!-- astrona:playground:renew -->

```sh
#!/usr/bin/env bash
set -euo pipefail

validate_manifest() {
  kubectl apply --dry-run=server -f "$MANIFEST"
}

show_difference() {
  kubectl diff -f "$MANIFEST" || test $? -eq 1
}

deploy_release() {
  kubectl apply -f "$MANIFEST"
  kubectl -n launch rollout status "deployment/$DEPLOYMENT" --timeout=120s
}

MANIFEST="${1:?usage: ci.sh <manifest> <deployment>}"
DEPLOYMENT="${2:?usage: ci.sh <manifest> <deployment>}"

validate_manifest
show_difference
deploy_release
echo "Pipeline finished."
```

The line `set -euo pipefail` makes the shell stop at the first command that fails. `kubectl diff` exits with 1 when there is a difference, which is a normal result here, so the function accepts exit code 1 and fails on any other code. Save a valid Deployment for `scout-green` as `deployment-scout-green.yaml`, with the namespace `launch`, and run the script:

```sh
chmod +x ci.sh
./ci.sh deployment-scout-green.yaml scout-green
```

Each stage prints its own output. If the manifest is invalid, the first stage fails and the script exits before anything reaches the cluster. If the rollout does not finish in 120 seconds, `rollout status` fails and so does the pipeline. A real pipeline tool does the same with jobs, but the principle is the one in these twenty lines: stages, exit codes and stopping on failure.

## What good CI looks like

A build that takes longer than ten minutes slows every developer, so teams split tests and run them in parallel. A flaky test, one that fails at random, trains people to rerun and ignore failures, so a team fixes or removes it. The main branch must stay releasable: when it breaks, the first job of the team is to repair it or revert the commit.

You can now classify a pipeline by who presses the last button. The next part looks at how the pipeline itself is stored and run.

## Common pitfalls

> [!WARNING]
> - A pipeline that rebuilds the artifact for each environment does not test what it releases. Build once and promote.
> - Continuous delivery is not continuous deployment. The difference is the manual approval before production.
> - A step that ignores exit codes passes when it should fail. Use `set -e` or the tool's equivalent.
> - Do not hide a flaky test behind automatic retries. Fix the cause.
