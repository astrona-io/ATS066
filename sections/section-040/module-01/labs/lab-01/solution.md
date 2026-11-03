# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Record the change cause, then label the template

Annotate first, so that the cause is already on the Deployment when the rollout starts:

```sh
kubectl -n starfleet annotate deployment scout kubernetes.io/change-cause="release 6.15.0 from rev-0042" --overwrite
```

Save this as `release-label.yaml`. A merge patch adds the label and leaves everything else as it is:

```yaml
spec:
  template:
    metadata:
      labels:
        release: rev-0042
```

```sh
kubectl -n starfleet patch deployment scout --patch-file release-label.yaml
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

A change to the pod template starts a rolling update. The old pods are replaced one after the other, and the command ends when both new pods are ready. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/labs/lab-01
```

The checks `change-cause-recorded`, `pods-labelled-with-release` and `rollout-complete` should pass. The two record checks still fail.

## Step 2: Read the digest and write the record

Read the identity of the image that the running pods use:

```sh
kubectl -n starfleet get pods -l app=scout -o jsonpath='{range .items[*]}{.status.containerStatuses[0].imageID}{"\n"}{end}'
```

Both lines should end in the same `@sha256:` value. Copy the part from `sha256:` to the end of the line. Save this as `release-record.yaml` and replace `DIGEST`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: release-scout
  namespace: starfleet
data:
  version: "6.15.0"
  digest: "sha256:DIGEST"
  source-revision: "rev-0042"
  approved-by: "platform-team"
```

```sh
kubectl apply -f release-record.yaml
```

Submit again. All five checks should pass.

## What each check proves

- `release-record` checks that the record has the four facts and that the source revision is `rev-0042`.
- `digest-matches-pods` compares the recorded digest with the `imageID` of every running pod, which is the verification step of a release.
- `change-cause-recorded` reads the annotation on the Deployment.
- `pods-labelled-with-release` checks the template label and the running pods.
- `rollout-complete` checks that the update finished and the image did not change.
