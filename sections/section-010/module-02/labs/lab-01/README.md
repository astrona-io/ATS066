---
estimated_duration: 30m
---

# Lab: Declare Scout Configuration With Kustomize And Remove Drift

Graded lab for the configuration module. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the behavior of `kubectl apply -k` over an object created with `kubectl create`, and the exact `kubectl diff` output.

The cluster starts with a hand-made `scout` Deployment (five replicas and a message in `env`) and a Secret `scout-token`. The learner writes a Kustomize base and overlay on their machine and applies it. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-066-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. The reference files are in `solution/files/`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-config-generated.sh` | Exactly one `scout-config-<hash>` ConfigMap with the overlay message |
| `validate-deployment-uses-generated-config.sh` | The template and both pods use it through `envFrom`; no `PODINFO_UI_MESSAGE` in `env` |
| `validate-applied-from-overlay.sh` | Label `environment=starfleet` on the objects, a last-applied annotation, selector still `app: scout` |
| `validate-secret-by-reference.sh` | `SCOUT_TOKEN` uses `secretKeyRef` to `scout-token/token`; no ConfigMap holds the value |
| `validate-declared-state-restored.sh` | Two available replicas, original image, no extra pods |

All checks fail before any change.
