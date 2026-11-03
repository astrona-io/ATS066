---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Desired State In Version Control

A file on one machine is better than a command, but it is not yet a practice. Configuration as Code means the files live in a version control system, usually Git, where every change has an author, a reason and a place in the history. This part puts a manifest in Git and uses `kubectl diff` to compare it with the cluster before anything is applied.

## What version control adds

Git stores each change as a commit. A commit has an author, a time and a message. A branch holds work in progress, and a pull request asks other people to review a branch before it joins the main branch. Four properties follow. Every change has a reason (the commit message). Every change was reviewed (the pull request). The state at any earlier time can be read (the history). A bad change can be undone with a new commit (a revert).

None of this is true for a hand change in the cluster. The cluster keeps the current state and not the history of how it got there.

## Put a file in Git

Create a directory with a repository and the manifest from the previous part. Save this as `deployment-scout.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
  labels:
    app: scout
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
```

Record it:

```sh
git init
git add deployment-scout.yaml
git commit -m "Declare the scout Deployment with two replicas"
```

The commit message states the intent. In a team, this commit goes through a pull request.

## Compare the file with the cluster

`kubectl diff -f` asks the API server what an apply would change and prints the difference. It changes nothing. Its exit code is `0` when there is no difference, `1` when there is a difference and more than `1` when the command itself failed.

```sh
kubectl diff -f deployment-scout.yaml
echo $?
```

If an earlier part left the Deployment at five replicas, the diff shows the line `replicas: 5` removed and `replicas: 2` added, and the exit code is `1`. If the cluster already matches, the exit code is `0`. A pipeline can use this exit code as a gate: a job that only compares can run on every pull request, and a job that applies runs after the merge.

## Review and revert a change

Change the replica count in the file to three and commit it:

```sh
git commit -am "Run three replicas of scout during the exercise"
git log --oneline
```

The log shows both commits. To undo the second one, create a new commit that reverses it:

```sh
git revert --no-edit HEAD
```

History keeps all three commits, and the file now says two replicas again. Apply the file to bring the cluster in line:

```sh
kubectl apply -f deployment-scout.yaml
```

The revert is itself a change with a record. This is why teams revert and apply, instead of resetting history: the history of what was in production stays truthful.

## What Git does not do

Git holds the desired state. It does not apply it. Something must carry the file to the cluster: a person with `kubectl`, a pipeline job or a GitOps agent. Git also does not tell you whether the cluster still matches the file. `kubectl diff` answers that for one moment, and a controller that compares continuously answers it for all time. Secrets need extra care because a value committed to Git stays in the history even after a later commit removes it.

The files and the history now give you a review step and a record. The next part looks at a harder question: when two tools write the same object, which one wins?

## Common pitfalls

> [!WARNING]
> - Never commit a Secret value. A deleted file is still in the history. Commit a reference or an encrypted form.
> - `git reset --hard` followed by a force push rewrites history. Use `git revert` on a shared branch.
> - A green `kubectl diff` proves the cluster matched the file at that moment only.
> - Do not apply from a local branch that nobody reviewed. The cluster then holds a state that the main branch does not.
