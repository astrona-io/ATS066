# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Recover live

Read the state, then undo the failed revision:

```sh
kubectl -n live get pods
kubectl -n live rollout history deployment/relay
kubectl -n live rollout undo deployment/relay
kubectl -n live rollout status deployment/relay --timeout=120s
```

The new pod showed an image pull error, and the old pods kept serving. After the undo the template has the good image again. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/capstone/labs/lab-01
```

The check `live-recovered` should pass.

## Step 2: Record the cause and promote

Annotate first, then apply the same label file to preview and then to live. Save this as `release-label.yaml`:

```yaml
spec:
  template:
    metadata:
      labels:
        release: r3
```

```sh
kubectl -n live annotate deployment relay kubernetes.io/change-cause="release r3 from rev-0107" --overwrite
kubectl -n preview patch deployment relay --patch-file release-label.yaml
kubectl -n preview rollout status deployment/relay --timeout=180s
kubectl -n live patch deployment relay --patch-file release-label.yaml
kubectl -n live rollout status deployment/relay --timeout=180s
```

Submit. The checks `release-promoted` and `same-digest-in-both` should pass.

## Step 3: Write the release record

Read the digest from the live pods and not from memory:

```sh
kubectl -n live get pods -l app=relay -o jsonpath='{range .items[*]}{.status.containerStatuses[0].imageID}{"\n"}{end}'
```

Save this as `release-record.yaml` and replace `DIGEST` with the part after `sha256:`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: release-relay
  namespace: live
data:
  version: "r3"
  digest: "sha256:DIGEST"
  source-revision: "rev-0107"
  approved-by: "platform-team"
```

```sh
kubectl apply -f release-record.yaml
```

## Step 4: Give the pipeline a narrow identity

Save this as `relay-pipeline.yaml`. The first rule names the Deployment. The second rule allows `list` and `watch`, which work on collections and are needed to follow a rollout:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: relay-pipeline
  namespace: live
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: relay-release
  namespace: live
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    resourceNames: ["relay"]
    verbs: ["get", "patch", "update"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: relay-pipeline-release
  namespace: live
subjects:
  - kind: ServiceAccount
    name: relay-pipeline
    namespace: live
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: relay-release
```

```sh
kubectl apply -f relay-pipeline.yaml
kubectl auth can-i patch deployment/relay -n live --as=system:serviceaccount:live:relay-pipeline
kubectl auth can-i get secrets -n live --as=system:serviceaccount:live:relay-pipeline
kubectl auth can-i patch deployment/relay -n preview --as=system:serviceaccount:live:relay-pipeline
```

The first answer is `yes`. The other two are `no`. Submit one last time. All six checks should pass.
