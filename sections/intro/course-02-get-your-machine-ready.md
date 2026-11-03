# Get Your Machine Ready

The hands-on steps run on your own computer. Each playground and lab starts a private single-node Kubernetes cluster in a container, so nothing touches a shared cluster.

## Tools to install

- The `astrona` command-line tool, which starts, grades and removes the environments.
- A container engine that kind can use, Podman or Docker, with about 4 GiB of free memory.
- `kubectl`, the Kubernetes command-line client. It also contains Kustomize, so `kubectl apply -k` and `kubectl diff -k` need no extra tool.
- OpenTofu, the `tofu` command. The infrastructure as code section needs it on your machine, because OpenTofu runs outside the cluster.
- A shell such as `bash` or `zsh`.

kind runs each Kubernetes node as a container, and `astrona` calls it for you. The start scripts and the cluster pull pinned container images, and `tofu init` downloads a provider, so the machine needs internet access.

## The commands used every day

Start a playground or a lab with `astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c <environment-path>`. Each page names the environment. Connect `kubectl` to it with `export KUBECONFIG="$(astrona kubeconfig <name>)"`. A kubeconfig is the file that tells `kubectl` which cluster and credentials to use. OpenTofu reads the same file when you set `KUBE_CONFIG_PATH`; the pages in that section show the exact steps.

Grade a lab with `astrona submit -c <lab-path>`. Remove an environment with `astrona destroy <name>`. Run one environment at a time, because each cluster needs memory.

## When a start goes wrong

If a start fails, read the last lines of the error. A failed image download usually means the network is not reachable, so run the command again. If memory is short, destroy other environments first. Destroy a half-started environment with `astrona destroy <name>` and start it again.
