# Security Checks In The Delivery Path - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the namespace `dockyard` with an unsafe `scout` Deployment (two replicas, root user, privileged container) and a Secret `scout-token`. No Pod Security label is set. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/dockyard.yaml` | The starting objects |
| `docs/overview.md` | What the environment contains and ideas to try |
