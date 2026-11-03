# Declarations Plans And Resource Lifecycle - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet workloads. No OpenTofu file exists. OpenTofu is not part of the cluster; install it on your machine. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-020-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | The starting objects |
| `docs/overview.md` | What the environment contains and ideas to try |
