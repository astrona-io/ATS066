---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Summary

DevOps is shared ownership of a service from commit to production, with the goal of delivering small changes often, safely and with fast feedback. It is a way of working and not a tool or a team name. The CALMS model names five parts: culture, automation, lean, measurement and sharing. DevSecOps puts security checks and duties into the same path. It moves checks earlier, which is called shifting left, and keeps the later checks too. A platform team supports this by offering shared services with a clear contract.

A feedback loop is the time from a change to a clear signal. A path has several loops of different length, and each problem should be caught in the shortest loop that can find it. In a cluster the signals are rollout status, events, logs, status fields and probes. A revision history explains the change only when someone records the reason with the `kubernetes.io/change-cause` annotation.

The four key metrics are deployment frequency, lead time for changes, change failure rate and time to restore service. Two measure speed and two measure stability, and high performing teams do well in both. The data comes from Git, the pipeline and the incident system, and the ReplicaSet history in the cluster holds a short part of it. Medians are better than averages, the numbers compare a team with its own past, and they must never be used to rank people.

A blameless review looks for causes in the system, produces a timeline and a short list of tracked actions that change the system, and does not name a person as the cause. Ownership must be queryable: recommended labels and an owner label allow selectors to find the team, and an annotation can point to the runbook. A platform makes these rules stay true by checking them in the pipeline or at admission.

Key facts:

- CALMS stands for culture, automation, lean, measurement and sharing.
- `kubectl rollout history` shows `kubernetes.io/change-cause` for each revision.
- Labels are matched by selectors; annotations are not.
- The cluster keeps ten old ReplicaSets by default.

<!-- astrona:playground:destroy -->
