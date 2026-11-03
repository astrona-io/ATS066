---
estimated_duration: 35m
---

# Lab: Declare A Hangar With OpenTofu

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: OpenTofu is not run by `astrona test`; the provider version `~> 2.35` and the use of `KUBE_CONFIG_PATH` are unverified; the labels do not prove that OpenTofu created the objects.

The learner writes OpenTofu files that declare a namespace, a ConfigMap and a Deployment, reads the plan, applies it and changes one setting through the files. The grader checks the live cluster. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-066-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-deployment.sh` | Deployment beacon has 2 available replicas, the pinned image, the label app=beacon and reads hangar-settings with envFrom. |
| `validate-namespace-declared.sh` | The namespace hangar exists with the label managed-by=opentofu. |
| `validate-pods-read-active-mode.sh` | Every running beacon pod has the environment variable mode=active. A pod that started before the ConfigMap changed still shows the old value. |
| `validate-settings-configmap.sh` | The ConfigMap hangar-settings has mode=active, owner=platform and the label managed-by=opentofu. |

All checks fail before any change.
