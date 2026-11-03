---
estimated_duration: 40m
---

# Lab: Reject Mutable Image Tags With An Admission Policy

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The CEL expression, the delay before a new binding takes effect and the exact error text of a denied dry run are unverified.

The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-04/labs/lab-01
astrona destroy ats-066-lab-030-04
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy-and-binding.sh` | The policy no-latest-tag and a binding of the same name exist, and the binding denies. |
| `validate-namespace-labelled.sh` | The namespace dock has the label supply-chain=checked. |
| `validate-latest-rejected-tagged-accepted.sh` | A Deployment with the tag latest is rejected and one with a version tag is accepted, both in dock. |
| `validate-scout-repaired.sh` | Scout runs two available replicas with the image ghcr.io/stefanprodan/podinfo:6.15.0. |

All checks fail before any change.
