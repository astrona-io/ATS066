---
estimated_duration: 40m
---

# Lab: Replace A Deployment With An Immutable Selector

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The wording of the immutable-field error and the EndpointSlice label query are unverified.

The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-066-lab-020-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-selector-replaced.sh` | The Deployment relay uses only the selector app.kubernetes.io/name=relay. |
| `validate-relay-available.sh` | Two relay pods run with the new label and no pod with the old label is left. |
| `validate-service-follows.sh` | The Service relay selects the new label and has two ready endpoints. |
| `validate-owner-label-kept.sh` | The Deployment still carries the label owner=platform. |

All checks fail before any change.
