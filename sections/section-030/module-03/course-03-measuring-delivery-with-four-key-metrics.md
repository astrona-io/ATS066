---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Measuring Delivery With Four Key Metrics

A team that wants to improve needs numbers about its delivery. Years of research by the DevOps Research and Assessment (DORA) group found four metrics that separate high performing teams from the rest. This part defines them, shows where a cluster holds some of the data and explains what the numbers can and cannot tell you.

## The four metrics

Two metrics measure speed and two measure stability.

- **Deployment frequency**: how often the team deploys to production.
- **Lead time for changes**: how long a change takes from commit to running in production.
- **Change failure rate**: the share of deployments that cause a failure in production and need a fix, a rollback or a patch.
- **Time to restore service**: how long it takes to recover when a failure in production affects users. Newer DORA reports call this failed deployment recovery time.

Later reports added reliability as a fifth measure. The important finding is that speed and stability do not trade against each other. Teams that deploy small changes often also fail less and recover faster, because a small change is easy to understand and to undo.

## Where the data comes from

The data comes from the tools of the path: the Git history for commit times, the pipeline for build and deployment times, the incident system for failures and recovery. The cluster holds part of it too. Each revision of a Deployment is a ReplicaSet, and the ReplicaSet records when it was created and which revision it is. Print them for `scout`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get replicasets -l app=scout \
  -o 'custom-columns=NAME:.metadata.name,REVISION:.metadata.annotations.deployment\.kubernetes\.io/revision,CREATED:.metadata.creationTimestamp'
```

Each row is one revision with its creation time. The number of rows in a period approximates the deployment frequency of that Deployment. The default history limit is ten ReplicaSets (`revisionHistoryLimit`), so the cluster alone cannot give a long record, and a pipeline must store deployment events elsewhere.

## Compute lead time

Lead time needs two timestamps: the commit time and the time the new version ran. Git gives the first one:

```sh
git log -1 --format=%cI
```

The ReplicaSet gives the second. The difference is the lead time of that change. To compute it for many changes you collect the pairs automatically, which is usually done by the pipeline writing the commit time into an annotation on the Deployment. A team then reports the median over a month and not a single value, because one slow change distorts an average.

## Change failure rate and time to restore

These two need a definition of failure that the team agrees on in advance: a rollback, a hot fix, an alert that fired within an hour of a deployment. Count the failed deployments and divide by all deployments. For recovery time, record when the incident started and when service returned. The rollout history helps here. A rollback reuses an older ReplicaSet and gives it the newest revision number, so the history shows when the service returned to a known good template.

## What numbers can mislead

Measurement drives behaviour. If a team is judged on deployment frequency, it may split changes into empty ones. If the failure rate is used to punish, teams hide failures. Use the numbers to find where the path is slow, compare a team with its own past and never rank people with them. A metric is a question, not an answer: a long lead time raises the question where the change waited, in review, in the build or in an approval.

The numbers give a team an honest view of its delivery. The next part covers what to do after a failure, and how to make sure that someone can answer when it happens.

## Common pitfalls

> [!WARNING]
> - The cluster keeps only a limited number of old revisions. Store deployment records outside it.
> - Do not use an average for lead time. Use the median and a high percentile.
> - Do not compare teams by these metrics. Their services and risks differ.
> - A change failure rate of zero for a month on three deployments is not good news, it is too little data.
