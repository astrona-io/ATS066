---
draft: true
exam_objectives:
- CI and CD
---
# Deployment Strategies

The last stage of a pipeline replaces the running version with a new one. How it does this decides the risk of the release, the extra capacity it needs and how fast the team can go back. This part compares four strategies and performs a blue-green switch with a Service selector.

## The four strategies

**Recreate** stops all pods of the old version and then starts the new ones. It is simple, needs no extra capacity and causes downtime. It suits versions that cannot run side by side, such as a change of database schema that the old code cannot read.

**Rolling update** replaces pods a few at a time. It is the default of a Kubernetes Deployment. The fields `maxSurge` and `maxUnavailable` control how many pods are added and removed at once. Both versions run during the update, so they must be compatible. Rollback is another rolling update in the other direction.

**Blue-green** runs two full copies. The blue environment serves users. The team deploys the new version as green next to it, tests it and then moves all traffic at once. Rollback is a switch back, and it is almost instant. The cost is double capacity during the release, and the data store must work with both versions.

**Canary** sends a small share of traffic to the new version first, watches error rate and latency, and increases the share step by step. If the numbers get worse, the share goes back to zero. It limits the number of users who meet a bad release. It needs good measurement. Tools such as Argo Rollouts, Flagger and service meshes automate the steps.

## Perform a blue-green switch

The `launch` namespace runs `scout-blue` and a Service `scout` that selects pods with `version: blue`. Look at the Service and its endpoints:

<!-- astrona:playground:renew -->

```sh
kubectl -n launch get service scout -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n launch get endpointslices -l kubernetes.io/service-name=scout
```

Deploy the green version next to blue. Save this as `deployment-scout-green.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout-green
  namespace: launch
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

Apply it and wait until it is ready:

```sh
kubectl apply -f deployment-scout-green.yaml
kubectl -n launch rollout status deployment/scout-green --timeout=120s
```

Users still reach blue only, because the Service selector has not changed. This is the moment to test green, for example with a port-forward to one of its pods. The switch is one change of the selector:

```sh
kubectl -n launch patch service scout -p '{"spec":{"selector":{"app":"scout","version":"green"}}}'
kubectl -n launch get endpointslices -l kubernetes.io/service-name=scout
```

The endpoints now list the green pods. Traffic moved at once, and the blue pods still run, unused. To roll back, patch the selector back to `blue`. When green has proven itself, scale blue down to save capacity but keep one replica for a while:

```sh
kubectl -n launch scale deployment/scout-blue --replicas=1
```

## A simple canary

A Service sends requests to every ready pod that matches its selector, in roughly equal shares. If the selector only has `app: scout`, both Deployments are behind it. With nine blue pods and one green pod, about one request in ten reaches green. The replica ratio is a rough control. It cannot give exactly 1 percent, and it changes when a pod restarts or a node is lost. Precise shares need a mesh or an ingress controller with weights.

## Readiness is the gate

Every strategy relies on readiness. A pod that receives traffic before it is ready returns errors. The readiness probe in the green Deployment tells Kubernetes when a pod may join the endpoints. Never switch a selector to a Deployment that is not fully available.

The strategies differ in cost and speed, and none is free. The final part shows how a CI pipeline and a GitOps agent can run these steps without giving the pipeline access to the cluster.

## Common pitfalls

> [!WARNING]
> - Switching a Service selector to pods that are not ready sends users to errors. Wait for `rollout status` first.
> - Blue and green share the database. A schema change must work for both versions.
> - Replica counts only approximate a canary share. Do not promise an exact percentage.
> - Remove the old version only after the new one has run long enough to prove itself.
