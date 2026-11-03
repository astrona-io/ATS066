---
estimated_duration: 60m
---

# Lab: Bring A Hand-Made Depot Under OpenTofu

Capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: OpenTofu is not run by `astrona test`; import, replacement and `prevent_destroy` behaviour and the provider version are unverified; the labels do not prove that OpenTofu managed the objects.

The learner imports a namespace and a ConfigMap, declares a quota, a Deployment and a Service, changes one setting through the files and reverts a manual scale. The grader compares unique identifiers and checks the live objects. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-066-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-imported-objects.sh` | The namespace depot and the ConfigMap depot-settings keep their unique identifiers and carry the label managed-by=opentofu. |
| `validate-quota-declared.sh` | ResourceQuota depot-quota allows 10 pods and carries managed-by=opentofu. |
| `validate-relay-deployment.sh` | Deployment relay has 2 replicas, all available, the pinned image, envFrom of depot-settings, the label managed-by=opentofu and exactly 2 pods that are not terminating (the manual scale to 3 was reverted). |
| `validate-relay-service.sh` | Service relay selects app=relay, exposes port 80 to target port 9898 and carries managed-by=opentofu. |
| `validate-settings-tier-gold.sh` | Depot-settings holds tier=gold. |

All checks fail before any change.
