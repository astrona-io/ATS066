# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Find the failing readiness probe

Read the state of the rollout. The Deployment has old and new pods, and the new ones are not ready:

```sh
kubectl -n starfleet get pods -l app=scout
kubectl -n starfleet rollout status deployment/scout --timeout=20s
```

The new pods are `Running` with `0/1` in the `READY` column, and the status command reports that it is waiting for the rollout. The container works, so read the events of one new pod:

```sh
kubectl -n starfleet describe pod -l app=scout | grep -i "readiness probe"
```

The lines say that the readiness probe failed with HTTP status 404 for the path `/missing`. The application answered, so the path is wrong.

## Step 2: Record the cause and fix the template

Annotate first, so that the text is copied to the revision that the fix creates:

```sh
kubectl -n starfleet annotate deployment/scout --overwrite kubernetes.io/change-cause="release scout v2 with a working readiness probe"
```

Save this as `scout-fix.yaml`. It corrects the probe, sets the strategy and sets the two timing fields in one patch:

```yaml
spec:
  minReadySeconds: 10
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
        - name: scout
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

Apply it:

```sh
kubectl -n starfleet patch deployment scout --patch-file scout-fix.yaml
```

The probe change is inside the pod template, so it creates a third revision. The other fields are outside the template and take effect with that rollout. The message `scout v2` stays in the template from the second revision, because the patch merges into it.

## Step 3: Wait for the rollout and check it

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=240s
kubectl -n starfleet get replicasets -l app=scout
kubectl -n starfleet get pods -l app=scout
```

With `maxUnavailable: 0`, the controller creates one new pod, waits until it is ready for 10 seconds and then removes one old pod. Expect the rollout to take about a minute. At the end, one ReplicaSet has 3 pods and the others have none. Read the history:

```sh
kubectl -n starfleet rollout history deployment/scout
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/labs/lab-01
```

All six checks pass. If `rollout-complete` fails, wait until the old pods are gone and submit again. If `release-delivered` fails, a pod still has the old template: check `kubectl -n starfleet get pods -l app=scout -o wide`. Clean up with `astrona destroy ats-066-lab-010-01`.
