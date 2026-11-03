# Software Supply Chain Security And Admission Policy - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-030-04
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`). The namespace `dock` holds a `scout` Deployment (two replicas) that uses the tag `latest`. No admission policy exists and the namespace has no label. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-030-04
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/dock.yaml` | The starting objects |
| `docs/overview.md` | What the environment contains and ideas to try |
