---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Summary

A Deployment replaces pods through ReplicaSets. The Deployment controller hashes the pod template, creates a ReplicaSet for each distinct template and scales the new and old ReplicaSets against each other. Only a change inside the pod template creates a revision. A change to the replica count, the strategy or the timing fields changes how the controller behaves and does not replace a pod.

The speed of a rollout comes from two budgets. `maxSurge` limits the pods above the desired count and rounds up when it is a percentage. `maxUnavailable` limits the missing pods and rounds down. With `maxUnavailable: 0`, the service keeps all its capacity and the cluster must have room for the extra pods. The readiness probe decides when a new pod counts as available, `minReadySeconds` makes that count wait for stable readiness, and `progressDeadlineSeconds` sets when the controller reports that progress has stopped.

A stalled rollout leaves evidence at four levels: the Deployment conditions, the ReplicaSets, the pod states and the events. The pod state names the area to fix: scheduling, the image, the container or the probe. A deadline condition is a report. It does not roll anything back.

A rollback is a new rollout of an old pod template taken from the retained ReplicaSets. It does not restore other objects, data changes or the strategy fields. A release is good when the controller status, a request through the Service and a user operation all agree.

Key facts:

- The label `pod-template-hash` ties pods to their ReplicaSet.
- Defaults: `maxSurge` and `maxUnavailable` are 25 percent, `progressDeadlineSeconds` is 600 and `revisionHistoryLimit` is 10.
- `kubernetes.io/change-cause` gives each revision a readable reason.
- Mutable image tags make a rollback unpredictable.

<!-- astrona:playground:destroy -->
