---
estimated_duration: 20m
---

# Lab: Repair A Stalled Rollout

Graded lab for the rolling update module. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The cluster starts with `scout` at three replicas and a second revision that never becomes ready because its readiness probe checks a missing path. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-066-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-readiness-probe-fixed.sh` | The `scout` template has an HTTP readiness probe on `/readyz` and the original image |
| `validate-strategy-keeps-capacity.sh` | `RollingUpdate` with `maxUnavailable` 0 and `maxSurge` 1 |
| `validate-timing-fields.sh` | `minReadySeconds` at least 10, deadline 30 to 120 seconds and above `minReadySeconds` |
| `validate-rollout-complete.sh` | 3 updated, ready and available replicas, latest generation observed, no `ProgressDeadlineExceeded` |
| `validate-release-delivered.sh` | The template and all 3 running pods carry `PODINFO_UI_MESSAGE=scout v2` (rejects a rollback) |
| `validate-change-cause-recorded.sh` | A non-empty `kubernetes.io/change-cause` and at least two revisions |

Open risk: the new pods of the broken revision need a few seconds to exist; the bootstrap does not wait for them because the rollout never finishes.
