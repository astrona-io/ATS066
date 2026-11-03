# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Add the ownership labels

Look at the labels now:

```sh
kubectl -n ops get deployments --show-labels
```

Only `app` is set. Add the labels:

```sh
kubectl -n ops label deployment/scout app.kubernetes.io/part-of=starfleet owner=scout-team
kubectl -n ops label deployment/probe app.kubernetes.io/part-of=starfleet owner=probe-team
kubectl -n ops get deployments -l owner=scout-team
```

The last command lists `scout` only. Labels on the Deployment object do not restart the pods. Run `astrona submit`: the label check passes.

## Step 2: Name the runbooks

Annotate both Deployments:

```sh
kubectl -n ops annotate deployment/scout runbook=runbooks/scout.md
kubectl -n ops annotate deployment/probe runbook=runbooks/probe.md
```

Run `astrona submit`: the annotation check passes.

## Step 3: Change scout and record why

Record the reason first, so that the new ReplicaSet carries it, and then change the pod template:

```sh
kubectl -n ops annotate deployment/scout kubernetes.io/change-cause="Show the ops banner message" --overwrite
kubectl -n ops set env deployment/scout PODINFO_UI_MESSAGE="ops banner"
kubectl -n ops rollout status deployment/scout --timeout=240s
kubectl -n ops rollout history deployment/scout
```

The history lists two revisions. Revision 1 has no change cause, and revision 2 shows the text you wrote. Run `astrona submit`. All four checks pass.
