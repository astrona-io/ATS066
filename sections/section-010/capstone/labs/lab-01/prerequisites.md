# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` (Kustomize is built into it), `jq` and a text editor.
- You can write a Kustomize base and overlay, read a rollout with `kubectl rollout status`, and know how a Deployment replaces pods.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the `scout` service in the namespace `outpost`. You create the Kustomize files in a new, empty directory on your machine.
