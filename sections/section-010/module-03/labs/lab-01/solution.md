# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Read who owns the fields

Show the managed fields of the hand-made Deployment:

```sh
kubectl -n hold get deployment scout --show-managed-fields -o yaml
```

The `managedFields` list has an entry from the manager `kubectl-create` with the operation `Update`. That manager owns `spec.replicas` and the image. Run `astrona submit`: all four checks fail.

## Step 2: Write the file

Save this as `scout.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scout-settings
  namespace: hold
data:
  mode: careful
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: hold
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
          env:
            - name: MODE
              valueFrom:
                configMapKeyRef:
                  name: scout-settings
                  key: mode
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

## Step 3: Dry run and read the conflict

Ask the API server what the apply would do:

```sh
kubectl apply --server-side --field-manager=release-pipeline --dry-run=server -f scout.yaml
```

The request fails with a conflict. The message names the manager `kubectl-create` and the fields `.spec.replicas` and `.data.mode`. The new values differ from the values that another manager owns, so the server refuses to overwrite them without a decision.

## Step 4: Take over the fields

The file is the intended owner. Apply it again and force the conflicts:

```sh
kubectl apply --server-side --field-manager=release-pipeline --force-conflicts -f scout.yaml
kubectl -n hold rollout status deployment/scout --timeout=240s
```

Run `astrona submit`. All four checks pass. Apply the same command once more and the objects report `serverside-applied` without a change to the replica count, which shows that the apply is repeatable.
