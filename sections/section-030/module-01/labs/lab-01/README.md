---
estimated_duration: 35m
---

# Lab: Build A Platform Contract For An Application Team

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The exact text of Forbidden and quota messages is not checked; `--as` checks need the administrator identity of the lab.

The learner creates an identity, a Role without wildcards, a quota, default limits and an owner label. The grader asks the API server what the identity may do. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-066-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-default-limits.sh` | A LimitRange in starfleet gives containers a default CPU request of 50m, a default memory request of 64Mi and a default memory limit of 128Mi. |
| `validate-owner-label.sh` | The scout Deployment has the label owner=scout-team and still has two available replicas. |
| `validate-quota.sh` | A ResourceQuota in starfleet limits pods to 6, CPU requests to 500m and memory requests to 512Mi. |
| `validate-role-bound-without-wildcards.sh` | The RoleBinding gives a Role of starfleet to scout-team, and no rule of that Role uses a wildcard. |
| `validate-team-access.sh` | Scout-team can deploy in starfleet and nothing more. |

All checks fail before any change.
