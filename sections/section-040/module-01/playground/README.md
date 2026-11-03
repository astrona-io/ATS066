# Build And Release Pipelines - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet workloads. There is no CI server. Your machine plays the pipeline. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | The starting objects |
| `docs/overview.md` | What the environment contains and ideas to try |
