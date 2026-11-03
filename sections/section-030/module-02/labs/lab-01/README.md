---
estimated_duration: 40m
---

# Lab: Enforce Pod Security And Restrict The Deployer

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: The podinfo image has a non-numeric user, so a numeric runAsUser is required; Pod Security behaviour on the kind node is unverified.

The learner makes a namespace enforce the restricted level, repairs the pod specification, reads a Secret by reference and creates a deployment identity with least privilege. The grader reads the live objects and asks the API server. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-066-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-deploy-identity-least-privilege.sh` | Scout-deploy can update only the Deployment scout in dockyard, cannot read Secrets, and has no token mounted by default. |
| `validate-pod-security-enforced.sh` | The namespace dockyard enforces and warns at the restricted level. |
| `validate-scout-available.sh` | Scout has two replicas, all available, with the original image. |
| `validate-scout-restricted.sh` | Two scout pods run with a restricted-compliant security context. |
| `validate-secret-by-reference.sh` | SCOUT_TOKEN refers to the Secret scout-token key token, and no ConfigMap or plain env value holds the token. |

All checks fail before any change.
