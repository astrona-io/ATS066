---
estimated_duration: 40m
---

# Capstone: Deliver A Configuration Change Safely

Graded capstone for the configuration section. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact `kubectl diff` output, the rollout timing with `minReadySeconds`, and the name hash.

The cluster starts with the `scout` service in `outpost`: a plain ConfigMap with a fixed name, a Secret, and a risky update strategy without a readiness probe. The learner builds a Kustomize base and overlay, delivers the new message with a safe rollout, removes the old ConfigMap and records evidence. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-066-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. The reference files are in `solution/files/`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-config-generated.sh` | One `scout-settings-<hash>` ConfigMap with `scout v2` and the overlay label; the old one is gone |
| `validate-deployment-uses-generated-config.sh` | The template and 3 pods use it; overlay label, last-applied annotation, selector unchanged |
| `validate-safe-rollout-settings.sh` | 1 surge, 0 unavailable, `minReadySeconds` at least 10, deadline 30 to 120, probe on `/readyz` |
| `validate-rollout-complete.sh` | Three updated, ready and available replicas, no `ProgressDeadlineExceeded` |
| `validate-secret-kept-out-of-config.sh` | `secretKeyRef` to `scout-key/api-key`, Secret unchanged, no ConfigMap holds the value |
| `validate-release-evidence.sh` | `release-evidence` matches the live name, revision, a UTC time and 3 replicas |

All checks fail before any change.
