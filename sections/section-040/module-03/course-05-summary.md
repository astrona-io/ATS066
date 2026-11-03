---
draft: true
exam_objectives:
- CI and CD
---
# Summary

Continuous integration means merging into a shared branch often, with an automated build and test on each change, so that defects are found while they are small. Continuous delivery means that every change that passes the pipeline can be released, and a person decides when. Continuous deployment removes that decision and releases every passing change. A pipeline builds the artifact once and promotes the same artifact through its stages, with cheap checks first.

A pipeline is defined as code in the repository. Its parts are triggers, jobs, steps, runners, artifacts, caches, secrets and environments. A step is a command or a container, and its exit code decides success. A Kubernetes Job shows the same idea: exit code 0 completes, any other code gives the condition `Failed`. Pipeline files need the same care as code: pinned versions, minimal permissions and no secrets for untrusted pull requests.

The four deployment strategies trade risk, cost and speed. Recreate causes downtime and needs no extra capacity. A rolling update replaces pods in steps and needs compatible versions. Blue-green runs two environments and switches traffic at once, with an instant rollback and double capacity. A canary sends a small share to the new version and widens it as the measurements stay good. Readiness probes gate all of them.

GitOps separates the build from the deployment. The CI pipeline builds, tests and signs the artifact, and writes the new image reference to a configuration repository. An agent in the cluster pulls and applies it. The pipeline needs no cluster credentials, drift is corrected, and a revert is a rollback. The configuration repository then controls production and needs protected branches and reviews.

Key facts:

- Continuous delivery has a manual release step; continuous deployment does not.
- Exit code 0 means success for a pipeline step.
- A blue-green switch changes the Service selector from one `version` label to the other.
- `kubectl diff -k .` shows what a Kustomize render would change.

<!-- astrona:playground:destroy -->
