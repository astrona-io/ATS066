---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Feedback Loops And Signals

A change is only useful when its author learns quickly whether it worked. The time between making a change and getting a clear signal is a feedback loop, and short loops are the main reason that DevOps teams move fast and safely. This part lists the loops of a delivery path and shows the signals that a Kubernetes cluster gives for the loops closest to production.

## The loops of a delivery path

Each stage of the path has its own loop. The editor and local tests answer in seconds. The continuous integration (CI) build and its tests answer in minutes. A review answers in hours. A deployment to staging and its checks answer in minutes to hours. Production monitoring and user reports answer in minutes to days. The rule is to catch each problem in the shortest loop that can find it. A syntax error should never reach production, and a performance problem under real load may only appear there.

Feedback must also be actionable. A message that says "failed" costs time. A message that says which check failed, on which object and why, lets the author fix it at once.

## Signals from the cluster

Kubernetes produces four kinds of signals about a workload. Events record things that happened to an object. Logs hold what the application wrote. Status fields show the current state. Probes report health. Read them in this order when a change looks wrong.

Start with the rollout, which tells whether the new version became ready:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet rollout status deployment/scout
```

The command returns when the rollout is complete, or keeps waiting and reports that it is waiting for replicas to become available. In a pipeline, use `--timeout=120s` so that the job fails instead of waiting forever.

Events show the reasons behind a state. List recent events for the namespace, oldest first:

```sh
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
```

Each event has a type (`Normal` or `Warning`), a reason such as `Scheduled`, `Pulled` or `Unhealthy`, the object it concerns and a message. A `Warning` is the first thing to read.

Logs show the application's own view:

```sh
kubectl -n starfleet logs deployment/scout --tail=20
```

For a Deployment, `kubectl` picks one pod. Add `--all-containers` or select a pod by name when you need a specific one. The status of a Deployment gives the counts that dashboards usually plot:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.status.replicas} {.status.readyReplicas} {.status.availableReplicas}{"\n"}'
```

The three numbers are the replicas that exist, those that are ready and those that have been ready long enough to count as available.

## Record why a change happened

A signal tells you what the system does. A record tells you why it was changed. Kubernetes keeps a revision history for each Deployment. A revision has no reason unless someone writes one. The annotation `kubernetes.io/change-cause` holds a short text that `kubectl rollout history` shows. Add it before the next change:

```sh
kubectl -n starfleet annotate deployment/scout kubernetes.io/change-cause="Raise log detail while testing" --overwrite
kubectl -n starfleet rollout history deployment/scout
```

The history table shows the revision numbers and the change cause of each. In a pipeline the job writes this annotation with the commit identifier, so a revision links back to the commit that produced it.

## Alerts and the human loop

Signals only help when someone looks at them. An alert is a signal that wakes a person, and it must point to something the person can act on. Too many alerts teach people to ignore them. A good alert names the service, the symptom the user sees and a runbook that lists first steps. The last part of this module covers the runbook and the review that follows an incident.

The loops now have a form you can read. The next part turns this data into numbers that a team can follow over time.

## Common pitfalls

> [!WARNING]
> - `kubectl rollout status` without a timeout can wait for a long time in a pipeline.
> - Events are kept for about one hour by default. Read them soon after the problem.
> - `kubectl logs deployment/scout` shows one pod only. A failing pod may be a different one.
> - A revision without `kubernetes.io/change-cause` leaves the history table blank for that revision.
