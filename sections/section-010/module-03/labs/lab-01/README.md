---
estimated_duration: 40m
---

# Lab: Take Over Imperative Objects With Server-Side Apply

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: Server-side apply conflict messages and the manager name `kubectl-create` on this node are unverified.

The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-066-lab-010-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-deployment-owned-by-pipeline.sh` | The Deployment scout has fields that the field manager release-pipeline set with an apply operation. |
| `validate-settings-owned-by-pipeline.sh` | The ConfigMap scout-settings holds mode careful and release-pipeline owns the field. |
| `validate-scout-scaled-and-available.sh` | Deployment scout has two replicas and both are available. |
| `validate-mode-from-configmap.sh` | The container reads MODE from the ConfigMap scout-settings, key mode, and no literal value is set. |

All checks fail before any change.
