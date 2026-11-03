# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-03/labs/lab-01
```

## Step 1: Create the green Deployment

Save this as `deployment-scout-green.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout-green
  namespace: launch
  labels:
    app: scout
    version: green
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
      version: green
  template:
    metadata:
      labels:
        app: scout
        version: green
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          env:
            - name: PODINFO_UI_MESSAGE
              value: green release
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

The selector and the pod labels both include `version: green`, so the Deployment never adopts blue pods. Apply it and wait:

```sh
kubectl apply -f deployment-scout-green.yaml
kubectl -n launch rollout status deployment/scout-green --timeout=240s
```

Run `astrona submit`. The green check passes. The others fail.

## Step 2: Switch the Service

Users still reach blue. Move the selector in one patch:

```sh
kubectl -n launch patch service scout -p '{"spec":{"selector":{"app":"scout","version":"green"}}}'
kubectl -n launch get endpointslices -l kubernetes.io/service-name=scout
```

The endpoint slice now lists the two green pod addresses. Run `astrona submit`. The selector check and the endpoint check pass.

## Step 3: Keep blue small

```sh
kubectl -n launch scale deployment/scout-blue --replicas=1
kubectl -n launch rollout status deployment/scout-blue --timeout=120s
```

Run `astrona submit`. All four checks pass.

To roll back in a real release, patch the selector back to `version: blue` and scale blue up again.
