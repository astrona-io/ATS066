# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Look at the live state

```sh
kubectl -n outpost get deployment scout -o jsonpath='{.spec.strategy}{"\n"}'
kubectl -n outpost get configmaps
kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}{"\n"}'
```

The strategy is `RollingUpdate` with `50%` for both limits, there is only the ConfigMap `scout-settings` with a fixed name, and the revision is `1`. Create the working directory:

```sh
mkdir -p outpost-config/base outpost-config/overlays/outpost
cd outpost-config
```

## Step 2: Write the base

Save this as `base/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      serviceAccountName: scout
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          env:
            - name: PODINFO_UI_MESSAGE
              valueFrom:
                configMapKeyRef:
                  name: scout-settings
                  key: message
            - name: SCOUT_API_KEY
              valueFrom:
                secretKeyRef:
                  name: scout-key
                  key: api-key
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              memory: 64Mi
```

Save this as `base/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: scout
spec:
  selector:
    app: scout
  ports:
    - name: http
      port: 80
      targetPort: http
```

Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
configMapGenerator:
  - name: scout-settings
    literals:
      - message=scout v2
```

The files hold the name of the Secret and the key, and never the key value.

## Step 3: Write the overlay

Save this as `overlays/outpost/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: outpost
resources:
  - ../../base
replicas:
  - name: scout
    count: 3
labels:
  - pairs:
      environment: outpost
    includeSelectors: false
patches:
  - path: safe-rollout.yaml
```

Save this as `overlays/outpost/safe-rollout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  minReadySeconds: 10
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Render it and check that the ConfigMap is named `scout-settings-<hash>` and that the Deployment reads the same name:

```sh
kubectl kustomize overlays/outpost
```

## Step 4: Diff, apply and wait

```sh
kubectl diff -k overlays/outpost
kubectl apply -k overlays/outpost
kubectl -n outpost rollout status deployment/scout
```

The diff shows the new ConfigMap, the new strategy and the new template. The new name in the template starts a rollout, and with `maxUnavailable: 0` the old pods stay until a new pod has been ready for 10 seconds. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01 --keep
```

The checks `deployment-uses-generated-config`, `safe-rollout-settings`, `rollout-complete` and `secret-kept-out` pass. `config-generated` fails because the old ConfigMap still exists, and `release-evidence` fails because it does not exist yet.

## Step 5: Remove the old ConfigMap

No pod uses it now, so delete it:

```sh
kubectl -n outpost delete configmap scout-settings
```

## Step 6: Record the evidence

Read the live values and write them down:

```sh
CONFIG_MAP="$(kubectl -n outpost get configmaps -o name | grep 'scout-settings-' | cut -d/ -f2)"
REVISION="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')"
kubectl -n outpost create configmap release-evidence \
  --from-literal=config-map="$CONFIG_MAP" \
  --from-literal=revision="$REVISION" \
  --from-literal=observed-at="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --from-literal=replicas=3
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01
```

All six checks pass. If `rollout-complete` fails, wait until the old pods are gone and submit again. Clean up with `astrona destroy ats-066-capstone-010`.
