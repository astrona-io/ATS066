# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` (Kustomize is built into it) and a text editor.
- You know how to write a Deployment, a ConfigMap and a Kustomize `kustomization.yaml`, and how to use `kubectl apply -k`, `kubectl diff -k` and `kubectl kustomize`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads. You create the Kustomize files in a new, empty directory on your machine.
