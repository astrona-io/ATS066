---
estimated_duration: 30m
---

# Lab: Make Ownership And Change History Queryable

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: Whether the change-cause annotation reaches the new ReplicaSet in the same apply is unverified.

The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-066-lab-030-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-owner-labels.sh` | Both Deployments carry the part-of label and the right owner label. |
| `validate-runbook-annotations.sh` | Both Deployments name their runbook in an annotation. |
| `validate-change-recorded.sh` | Scout has at least two revisions and the newest revision records a change cause. |
| `validate-workloads-available.sh` | Scout has two available replicas and probe has one. |

All checks fail before any change.
