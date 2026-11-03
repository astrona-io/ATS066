---
estimated_duration: 35m
---

# Lab: Roll Back A Failed Release And Promote Correctly

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The behaviour of the stuck new pod (image pull error) depends on registry access of the node; the `imageID` format is assumed.

Production runs a failed release. The learner rolls back, promotes release r2 from staging to production with the same artifact and records the promotion. The grader compares digests across environments. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-066-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-environments-keep-own-settings.sh` | Each environment keeps its replica count, its own ConfigMap value and the envFrom reference. |
| `validate-production-rolled-back.sh` | Production scout uses the good image, has two available replicas and no pod that tries to run the broken image. |
| `validate-promotion-record.sh` | ConfigMap promotion-record in production has release=r2, from=staging and the digest that the production pods report. |
| `validate-release-in-both-environments.sh` | The template label release=r2 is set in staging and production, and the running pods carry it (one in staging, two in production). |
| `validate-same-digest-in-both.sh` | Every running scout pod in staging and production reports the same image digest. |

All checks fail before any change.
