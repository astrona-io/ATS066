---
estimated_duration: 60m
---

# Lab: Recover Production And Promote A Release With Evidence

Capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The behaviour of the stuck new pod depends on registry access; the `imageID` format is assumed.

The learner recovers production, promotes release r3 through preview and live with one artifact, records the evidence and gives the pipeline an identity that can update one Deployment only. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-066-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-live-recovered.sh` | Live relay uses the good image, has two available replicas and no pod that tries to run the broken image. |
| `validate-pipeline-identity.sh` | Relay-pipeline in live can update only the Deployment relay, cannot read Secrets or touch preview, and has no token mounted by default. |
| `validate-release-promoted.sh` | Release=r3 is on the template and the pods in preview (one) and live (two), and replicas and settings are untouched. |
| `validate-release-record.sh` | ConfigMap release-relay in live holds version r3, source-revision rev-0107, an approver and the digest that the live pods report; and the Deployment names rev-0107 in its change cause. |
| `validate-same-digest-in-both.sh` | Every running relay pod in preview and live reports the same digest. |

All checks fail before any change.
