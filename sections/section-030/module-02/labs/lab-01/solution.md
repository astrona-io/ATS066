# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Warn first, then repair the pods

Ask what the standard would say, without changing anything:

```sh
kubectl label --dry-run=server --overwrite namespace dockyard pod-security.kubernetes.io/enforce=restricted
```

The API server prints warnings that list the `scout` pods and the violations. Save this as `scout-restricted.yaml`. It sets every field that the standard names, a numeric user and the Secret reference together:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: dockyard
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
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          env:
            - name: SCOUT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: scout-token
                  key: token
          securityContext:
            runAsUser: 10001
            allowPrivilegeEscalation: false
            privileged: false
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              memory: 64Mi
```

Check it with a server-side dry run, apply it and wait:

```sh
kubectl apply --dry-run=server -f scout-restricted.yaml
kubectl apply -f scout-restricted.yaml
kubectl -n dockyard rollout status deployment/scout
```

## Step 2: Enforce the standard

Now the label cannot break the running pods, because they already meet the level:

```sh
kubectl label --overwrite namespace dockyard pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/warn=restricted
```

Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/labs/lab-01
```

The checks `pod-security-enforced`, `scout-restricted`, `secret-by-reference` and `scout-available` should pass. `deploy-identity-least-privilege` still fails.

## Step 3: Create the deployment identity

Save this as `scout-deploy.yaml`. The first rule names the Deployment, and the second allows `list` and `watch` for Deployments, because those verbs work on collections:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: scout-deploy
  namespace: dockyard
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: scout-update
  namespace: dockyard
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    resourceNames: ["scout"]
    verbs: ["get", "patch", "update"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: scout-deploy-update
  namespace: dockyard
subjects:
  - kind: ServiceAccount
    name: scout-deploy
    namespace: dockyard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: scout-update
```

Apply it and prove the limits:

```sh
kubectl apply -f scout-deploy.yaml
kubectl auth can-i patch deployment/scout -n dockyard --as=system:serviceaccount:dockyard:scout-deploy
kubectl auth can-i patch deployment/other -n dockyard --as=system:serviceaccount:dockyard:scout-deploy
kubectl auth can-i get secrets -n dockyard --as=system:serviceaccount:dockyard:scout-deploy
```

The first answer is `yes`. The other two are `no`. Submit once more and all five checks should pass.
