---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Blameless Reviews, Ownership And Runbooks

Incidents will happen, and the question is what the team learns. A review that looks for a guilty person teaches people to hide mistakes. A blameless review asks how the system allowed the mistake. This part describes the review, then makes ownership and operating knowledge visible on the objects of a cluster, so that the next incident starts faster.

## The blameless review

A blameless review, also called a post-incident review, is a meeting and a document after an incident. It assumes that people acted sensibly with the information they had. It asks what happened, in order, what made the failure possible, how it was detected, how it was fixed and what will prevent or shorten it next time. The output is a timeline, the contributing causes and a short list of actions with owners and dates.

An action such as "be more careful" is not an action. A good action changes the system: add a check to the pipeline, add an alert, make a rollback one command, add a limit. Actions that are never tracked are the most common failure of the practice.

## Ownership must be queryable

During an incident the first question is who owns this. Kubernetes has a set of recommended labels with the prefix `app.kubernetes.io/`, for example `app.kubernetes.io/name` and `app.kubernetes.io/part-of`. Teams add their own keys for ownership. Labels are short values that selectors can match. Annotations hold longer text that tools and people read but selectors cannot match, such as a link or a description.

Label the `scout` Deployment with its name, the larger system it belongs to and its owner:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet label deployment/scout app.kubernetes.io/name=scout app.kubernetes.io/part-of=starfleet owner=scout-team --overwrite
```

Add an annotation that names the runbook:

```sh
kubectl -n starfleet annotate deployment/scout runbook=runbooks/scout.md --overwrite
```

A label selector now answers the incident question:

```sh
kubectl get deployments --all-namespaces -l owner=scout-team
kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.annotations.runbook}{"\n"}'
```

The first command lists every Deployment that the team owns, in any namespace. The second prints the runbook location. Labels set on the Deployment object do not change the pod template, so these commands do not restart any pod.

## The runbook

A runbook is a short document for one service that tells the person on call what to do. It names the symptoms, the first checks, the commands for safe actions such as a rollback, who to contact next and what must never be done. A good runbook is tested in a practice exercise, kept next to the code and updated after every incident.

## Make the platform enforce it

Labels that depend on goodwill decay. A platform team can require them. An admission policy can reject a Deployment that has no `owner` label, a pipeline step can fail a pull request that lacks it and a nightly report can list objects without an owner. A rule that is checked by a tool stays true, and the author sees the message while the change is still in review.

You have now seen the whole loop of the module. Teams share responsibility, they learn from fast signals, they measure delivery, they review failures without blame and they keep ownership data on the objects themselves.

## Common pitfalls

> [!WARNING]
> - Do not name a person as the cause in a review. Name the conditions that made the mistake easy.
> - Put long text in annotations and short values in labels. Label values have length and character limits.
> - Do not use the owner's name of a person. People change teams. Use the team name.
> - A runbook that nobody has run is a guess. Test it.
