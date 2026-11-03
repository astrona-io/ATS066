---
estimated_duration: 30m
---

# Lab: Release An Artifact With Verifiable Evidence

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The `imageID` format reported by the runtime (digest after an at sign) is assumed and unverified.

The learner labels a release, records the change cause and writes a release record whose digest matches the running pods. The grader compares the record with the live pods. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-066-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-change-cause-recorded.sh` | The scout Deployment has a change-cause annotation that names rev-0042. |
| `validate-digest-matches-pods.sh` | The digest in the release record equals the digest that every running scout pod reports in its imageID. |
| `validate-pods-labelled-with-release.sh` | The pod template and both running pods carry the label release=rev-0042. |
| `validate-release-record.sh` | ConfigMap release-scout in starfleet holds version, digest, source-revision rev-0042 and approved-by. |
| `validate-rollout-complete.sh` | Scout has two available replicas, the original image, and no pod without the release label is left. |

All checks fail before any change.
