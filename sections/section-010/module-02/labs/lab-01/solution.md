# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Look at the live state

Read what the hand-made Deployment declares:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}{"\n"}'
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env}{"\n"}'
kubectl -n starfleet get secret scout-token -o jsonpath='{.data}{"\n"}'
```

The Deployment has `5` replicas and an environment entry `PODINFO_UI_MESSAGE` with the value `scout set by hand`. The Secret has a `token` key. Create the working directory and the folders:

```sh
mkdir -p scout-config/base scout-config/overlays/starfleet
cd scout-config
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
          envFrom:
            - configMapRef:
                name: scout-config
          env:
            - name: SCOUT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: scout-token
                  key: token
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
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
  - name: scout-config
    literals:
      - PODINFO_UI_MESSAGE=scout from the base
```

The file holds the name of the Secret and the key, and never the token.

## Step 3: Write the overlay

Save this as `overlays/starfleet/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: starfleet
resources:
  - ../../base
replicas:
  - name: scout
    count: 2
labels:
  - pairs:
      environment: starfleet
    includeSelectors: false
configMapGenerator:
  - name: scout-config
    behavior: merge
    literals:
      - PODINFO_UI_MESSAGE=scout from the overlay
```

Render it and check that the ConfigMap name has a hash and that the Deployment reads the same name:

```sh
kubectl kustomize overlays/starfleet
```

## Step 4: Diff, then apply

Preview what an apply would change in the live objects:

```sh
kubectl diff -k overlays/starfleet
echo $?
```

The diff shows the `replicas` change from 5 to 2, the new `envFrom` and `SCOUT_TOKEN` entries and the new label. The exit code is `1`, which means that differences were found. Apply it:

```sh
kubectl apply -k overlays/starfleet
```

The command warns that the Deployment has no last-applied annotation. That is expected, because it was created with `kubectl create`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01 --keep
```

The checks `config-generated`, `applied-from-overlay` and `secret-by-reference` pass. The check `deployment-uses-generated-config` fails, and that is the drift that the diff could not show.

## Step 5: Remove the hand-made setting

Read the template again:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env}{"\n"}'
```

The entry `PODINFO_UI_MESSAGE` with `scout set by hand` is still there. It was never in an applied manifest, so `kubectl apply` did not know it had to remove it. A value in `env` wins over `envFrom`, so the pods still show the hand-made message. Remove the entry with a patch that deletes it by name:

```sh
kubectl -n starfleet patch deployment scout --type=strategic -p '{"spec":{"template":{"spec":{"containers":[{"name":"scout","env":[{"name":"PODINFO_UI_MESSAGE","$patch":"delete"}]}]}}}}'
kubectl -n starfleet rollout status deployment/scout
```

Check that a new pod reads the overlay message:

```sh
kubectl -n starfleet exec deploy/scout -- printenv PODINFO_UI_MESSAGE
```

It prints `scout from the overlay`. Run `kubectl diff -k overlays/starfleet` again; the exit code is now `0` or only metadata lines remain. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01
```

All five checks pass. If `declared-state-restored` fails, wait until the old pods are gone and submit again. Clean up with `astrona destroy ats-066-lab-010-02`.
