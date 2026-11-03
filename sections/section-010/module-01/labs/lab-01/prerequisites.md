# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how to read a Deployment, its ReplicaSets and its pod events, and how to run `kubectl patch`, `kubectl rollout status` and `kubectl annotate`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`.
