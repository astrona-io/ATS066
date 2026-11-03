# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Read the failure and roll back

Look at production. The old pods still run, and one new pod cannot start:

```sh
kubectl -n production get pods
kubectl -n production rollout status deployment/scout --timeout=20s
kubectl -n production rollout history deployment/scout
```

The new pod shows an image pull error, and the status command reports that it is waiting for the rollout. The history lists two revisions. Undo the last one:

```sh
kubectl -n production rollout undo deployment/scout
kubectl -n production rollout status deployment/scout --timeout=120s
kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The image is `ghcr.io/stefanprodan/podinfo:6.15.0` again. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/labs/lab-01
```

The check `production-rolled-back` should pass.

## Step 2: Release to staging, then promote

Save this as `release-label.yaml`:

```yaml
spec:
  template:
    metadata:
      labels:
        release: r2
```

Apply it to staging, wait, and only then apply it to production. The order is the promotion:

```sh
kubectl -n staging patch deployment scout --patch-file release-label.yaml
kubectl -n staging rollout status deployment/scout --timeout=180s
kubectl -n production patch deployment scout --patch-file release-label.yaml
kubectl -n production rollout status deployment/scout --timeout=180s
```

The same file goes to both environments, so the artifact and the change are identical, and the replica counts and ConfigMaps are untouched. Submit again. The checks `release-in-both-environments`, `environments-keep-own-settings` and `same-digest-in-both` should pass.

## Step 3: Write the promotion record

```sh
kubectl -n production get pods -l app=scout -o jsonpath='{range .items[*]}{.status.containerStatuses[0].imageID}{"\n"}{end}'
```

Copy the part from `sha256:` to the end. Save this as `promotion-record.yaml` and replace `DIGEST`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promotion-record
  namespace: production
data:
  release: "r2"
  from: "staging"
  image-digest: "sha256:DIGEST"
```

```sh
kubectl apply -f promotion-record.yaml
```

Submit once more. All five checks should pass.
