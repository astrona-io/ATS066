---
estimated_duration: 40m
---

# Lab: Import Hand-Made Objects And Reconcile Drift

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: OpenTofu is not run by `astrona test`; `import` block behaviour and the provider version `~> 2.35` are unverified; the labels do not prove that OpenTofu managed the objects.

Three objects were made by hand and one was changed by hand. The learner imports them with import blocks, declares the intended state, applies the plan and removes the drift. The grader compares unique identifiers to tell an import from a delete and create. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-066-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-reconciled.sh` | Beacon has 2 replicas, all available, the original image and exactly 2 pods that are not terminating (no drift left). |
| `validate-managed-labels.sh` | The namespace, the ConfigMap and the Deployment carry the label managed-by=opentofu from the OpenTofu files. |
| `validate-objects-imported.sh` | The namespace, the ConfigMap and the Deployment are the objects that existed at the start (same unique identifiers), so they were imported and not deleted and created again. |
| `validate-settings-reconciled.sh` | Hangar-settings holds mode=active and owner=platform. |

All checks fail before any change.
