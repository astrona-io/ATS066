# CI/CD Concepts, Pipelines And Deployment Strategies - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-040-03
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`). The namespace `launch` holds `scout-blue` (two replicas) and a Service `scout` that selects `version: blue`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-040-03
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/scout-blue.yaml` | The starting objects |
| `docs/overview.md` | What the environment contains and ideas to try |
