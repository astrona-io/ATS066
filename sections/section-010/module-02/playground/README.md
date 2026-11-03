# Configuration As Versioned Input — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-066-playground-010-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads: `scout` (two replicas), `probe` and `shuttle` in
`starfleet`, and `drifter` in `outpost`. The learner creates ConfigMaps,
a Secret and a Kustomize base and overlay in a working directory on their own
machine and applies them with `kubectl`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-066-playground-010-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the
config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
