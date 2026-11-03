# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: See why the patch is refused

Read the live Deployment and Service:

```sh
kubectl -n yard get deployment relay -o yaml
kubectl -n yard get service relay -o yaml
```

Both use the label `app: relay`. Try the change that the teammate tried:

```sh
kubectl -n yard patch deployment relay --type=json -p='[{"op":"replace","path":"/spec/selector/matchLabels","value":{"app.kubernetes.io/name":"relay"}}]'
```

The API server answers that the selector field is immutable. A Deployment keeps its selector for its whole life, so the way forward is to replace the object. Run `astrona submit`: all four checks fail.

## Step 2: Write the new objects

Save this as `relay.yaml`. It keeps the `owner` label and changes the selector, the pod template and the Service together:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: yard
  labels:
    owner: platform
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: relay
  template:
    metadata:
      labels:
        app.kubernetes.io/name: relay
    spec:
      containers:
        - name: relay
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
---
apiVersion: v1
kind: Service
metadata:
  name: relay
  namespace: yard
spec:
  selector:
    app.kubernetes.io/name: relay
  ports:
    - name: http
      port: 80
      targetPort: http
```

## Step 3: Replace the Deployment and apply

Delete the old Deployment, then apply the file. The Service is updated in place, because its selector is a normal field:

```sh
kubectl -n yard delete deployment relay
kubectl apply -f relay.yaml
kubectl -n yard rollout status deployment/relay --timeout=240s
```

The service has no ready endpoint between the delete and the first ready pod. That gap is the price of the replacement. Run `astrona submit`. All four checks pass.
