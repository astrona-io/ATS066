---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# DevOps Goals And Working Agreements

Software used to move through teams in a line: developers wrote code, testers checked it and operators ran it. Each team had its own goal. Developers were measured on new features, and operators on stability, so the two goals pulled against each other and every handover cost time. DevOps removes the line. This part defines the goals, the practices behind them and the common misunderstandings.

## What DevOps is

DevOps is a set of practices and a culture in which one team, or closely working teams, own a service from the first commit to the running system. The goal is to deliver small changes to users often, safely and with fast feedback. The slogan is "you build it, you run it": the people who write the code also carry the responsibility when it fails, and that gives them a reason to make it easy to run.

DevOps is not a job title, a tool or a team that sits between developers and operators. Tools help, but a team that buys a pipeline and keeps the old handovers has not changed anything.

## The CALMS model

CALMS is a checklist of five parts of DevOps.

- **Culture**: shared goals and trust, and no blame when something fails.
- **Automation**: build, test, deployment and infrastructure changes run without manual steps.
- **Lean**: small batches of work, a limit on work in progress and removal of waiting.
- **Measurement**: decisions rely on data about delivery and about the running service.
- **Sharing**: knowledge, tools and lessons go across teams, in documents and in open code.

An exam question often gives a situation and asks which part is weak. A team that deploys by hand has a gap in automation. A team that never looks at failure data has a gap in measurement.

## Where security fits

DevSecOps applies the same idea to security. Security is not a gate at the end of the line, where a review blocks a release that is already finished. It is a set of checks and duties inside the delivery path from the start. The phrase "shift left" means to move a check earlier in the path, so that a developer learns about a problem while the change is still small. Examples are scanning dependencies on every commit, linting manifests in a pull request and refusing an unsafe pod at admission. Security teams then write rules, tools and guidance and no longer review each change by hand.

## What a platform contributes

In a large company not every team can build its own tools. A platform team builds shared services such as namespaces, access rules, pipelines and monitoring, and offers them as a product to application teams. The goal is to reduce the effort that each team spends on things that are not its business. A good platform has a clear contract: what it provides, what the application team owns and how to ask for a change.

## See a working agreement in the cluster

Many agreements become visible as Kubernetes objects. List the workloads of the example namespace and their labels:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get deployments --show-labels
```

Each Deployment shows the labels it carries. If a label such as `owner` is missing, nobody can tell who to call at night. The module returns to this later, when you add ownership data yourself.

Now compare two namespaces:

```sh
kubectl get namespaces --show-labels
```

A namespace is the unit where a platform team hands a space to an application team. What the team may do inside it is set by access rules, and the limits are set by quotas. A written agreement is weak unless an object enforces it.

You now know the goals and the vocabulary. The next part asks how a team learns whether a change worked, which is the job of feedback loops.

## Common pitfalls

> [!WARNING]
> - Do not describe DevOps as a tool or as a team name. It is a way of sharing responsibility.
> - "Shift left" does not mean to remove later checks. It means to add earlier ones and keep the later ones.
> - A pipeline without ownership still leaves a handover. Check who answers when it fails.
> - Security as the last step is the practice that DevSecOps was created to replace.
