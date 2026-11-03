---
estimated_duration: 40m
---

# Lab: Switch Traffic To A New Version With Blue-Green

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The readiness delay of the green pods and the time the endpoint slice needs to update are unverified.

The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-066-lab-040-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-green-deployed.sh` | The Deployment scout-green has two available replicas, the label version=green, a readiness probe and the message green release. |
| `validate-service-on-green.sh` | The Service scout selects app=scout and version=green. |
| `validate-endpoints-only-green.sh` | Every ready endpoint of the Service belongs to a green pod, and there are two. |
| `validate-blue-kept-for-rollback.sh` | The Deployment scout-blue still exists with exactly one available replica. |

All checks fail before any change.
