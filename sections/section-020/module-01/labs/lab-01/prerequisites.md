# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and a text editor.
- OpenTofu (the `tofu` command) installed on your machine, and you can write `.tf` files with a provider block, resources, `import` blocks and `lifecycle` rules.

The lab starts a single-node kind cluster (Kubernetes 1.35). You write your files in a new, empty directory on your machine.
