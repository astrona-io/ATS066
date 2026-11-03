# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Declare the limits

Save this as `bay-limits.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: bay-quota
  namespace: bay
spec:
  hard:
    pods: "6"
    requests.cpu: 500m
    requests.memory: 512Mi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: bay-defaults
  namespace: bay
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 50m
        memory: 64Mi
      default:
        memory: 128Mi
```

Apply it and read the quota. The two existing pods count against the ceiling:

```sh
kubectl apply -f bay-limits.yaml
kubectl -n bay describe resourcequota bay-quota
```

## Step 2: Repair relay, then enforce the standard

Warn first, so that you see what would break. Then save the repaired Deployment as `relay-restricted.yaml`:

```sh
kubectl label --dry-run=server --overwrite namespace bay pod-security.kubernetes.io/enforce=restricted
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: bay
  labels:
    app: relay
spec:
  replicas: 2
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: relay
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          env:
            - name: RELAY_TOKEN
              valueFrom:
                secretKeyRef:
                  name: relay-token
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

Apply the file after a server-side dry run, wait for the rollout and then set the labels:

```sh
kubectl apply --dry-run=server -f relay-restricted.yaml
kubectl apply -f relay-restricted.yaml
kubectl -n bay rollout status deployment/relay
kubectl label --overwrite namespace bay pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/warn=restricted
```

Submit. The checks `quota-and-defaults`, `pod-security-enforced` and `relay-restricted` should pass.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/capstone/labs/lab-01
```

## Step 3: Create the team identity

Save this as `bay-team.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bay-team
  namespace: bay
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: bay-deployer
  namespace: bay
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bay-team-deployer
  namespace: bay
subjects:
  - kind: ServiceAccount
    name: bay-team
    namespace: bay
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: bay-deployer
```

```sh
kubectl apply -f bay-team.yaml
kubectl auth can-i patch deployments -n bay --as=system:serviceaccount:bay:bay-team
kubectl auth can-i get secrets -n bay --as=system:serviceaccount:bay:bay-team
kubectl auth can-i list pods -n default --as=system:serviceaccount:bay:bay-team
```

The first answer is `yes` and the other two are `no`.

## Step 4: Write the record

Read the live values and write them down. Do not type values that you have not read:

```sh
kubectl get namespace bay -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}'
kubectl -n bay get resourcequota bay-quota -o jsonpath='{.spec.hard.pods}{"\n"}'
kubectl -n bay create configmap platform-record --from-literal=pod-security=restricted --from-literal=quota-pods=6 --from-literal=deployer=bay-team
```

Submit one last time. All six checks should pass. The check `platform-record` compares the record with the live namespace label and quota, so a record that was written before a change would fail after the change.
