---
estimated_duration: 60m
---

# Lab: Bring A Bay To A Safe Supported State

Capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: Pod Security behaviour on the kind node and the numeric user of the podinfo image are unverified.

The learner sets limits, enforces a security standard, repairs a Deployment, creates a narrow team identity and records the live settings. The grader compares the record with the live namespace label and quota. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-066-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-platform-record.sh` | The ConfigMap platform-record in bay states the settings that are live: pod-security, quota-pods and deployer. |
| `validate-pod-security-enforced.sh` | Bay enforces and warns at the restricted level. |
| `validate-quota-and-defaults.sh` | Bay has a ResourceQuota (6 pods, 500m CPU requests, 512Mi memory requests) and a LimitRange with container defaults. |
| `validate-relay-restricted.sh` | Two relay pods run with restricted settings and read the token by reference. |
| `validate-team-access-least-privilege.sh` | Bay-team can deploy in bay and has no other rights, and its Role has no wildcard. |

All checks fail before any change.
