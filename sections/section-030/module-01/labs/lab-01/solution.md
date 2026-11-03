# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Create the identity and the access rules

Save this as `scout-team.yaml`. The Role lists exact verbs and resources, and the empty string in `apiGroups` means the core API group:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: scout-team
  namespace: starfleet
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: scout-deployer
  namespace: starfleet
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods", "services"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: scout-team-deployer
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: scout-team
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: scout-deployer
```

Apply it and ask the API server what the identity may do:

```sh
kubectl apply -f scout-team.yaml
kubectl auth can-i patch deployments -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i delete deployments -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i patch deployments -n outpost --as=system:serviceaccount:starfleet:scout-team
```

The first answer is `yes` and the other three are `no`. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/labs/lab-01
```

The checks `team-access` and `role-bound-without-wildcards` should pass. The others still fail.

## Step 2: Create the quota and the default limits

Save this as `team-limits.yaml`. The quota ceilings are for the whole namespace, and the LimitRange values apply to each container that declares none:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: starfleet
spec:
  hard:
    pods: "6"
    requests.cpu: 500m
    requests.memory: 512Mi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: team-defaults
  namespace: starfleet
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 50m
        memory: 64Mi
      default:
        memory: 128Mi
```

Apply it and read the quota. The `Used` column shows the four existing pods:

```sh
kubectl apply -f team-limits.yaml
kubectl -n starfleet describe resourcequota team-quota
```

Submit again. The checks `quota` and `default-limits` should now pass.

## Step 3: Label the owner

```sh
kubectl -n starfleet label deployment scout owner=scout-team
kubectl -n starfleet get deployments -L owner
```

A label does not change the pod template, so no new pods start. Submit once more. All five checks should pass.

## What each check proves

- `team-access` asks the API server eight questions with `--as` and compares the answers.
- `role-bound-without-wildcards` finds the Role that the identity is bound to and rejects `*` in any verb, resource or group.
- `quota` and `default-limits` read the objects and compare the values.
- `owner-label` checks the label and that the replicas are still available.
