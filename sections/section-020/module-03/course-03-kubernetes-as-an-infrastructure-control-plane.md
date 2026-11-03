---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Kubernetes As An Infrastructure Control Plane

The Kubernetes API stores objects and notifies controllers when they change. Nothing in this design limits it to pods. A controller can watch an object that describes a database, a bucket or a whole cluster, and call the cloud provider to make it real. Tools such as Crossplane and Cluster API work this way. This part shows the two pieces they rely on, a custom resource and a controller, using an object that you define yourself.

## The reconcile loop

A controller is a program that watches objects of one kind and compares the `spec` (the state you want) with the world. When they differ, it acts and writes the result into `status`. It repeats this loop whenever the object changes and on a regular schedule. The Deployment controller works this way with ReplicaSets. A controller for cloud resources works the same way, but its actions are calls to a cloud API.

Compared with a one-off tool such as OpenTofu, a controller runs all the time. It corrects drift in minutes without anyone starting a run, and the desired state is stored in the cluster as objects and not in a state file. The price is that the cluster becomes critical: if it is lost, the record of what it manages must be restored from Git.

## Add a new kind of object

A CustomResourceDefinition (CRD) adds a new kind to the API server. The server then stores and validates objects of that kind, with no code of its own. Save this as `crd-bays.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: bays.fleet.example.com
spec:
  group: fleet.example.com
  scope: Namespaced
  names:
    plural: bays
    singular: bay
    kind: Bay
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: ["size"]
              properties:
                size:
                  type: integer
                  minimum: 1
                  maximum: 10
      additionalPrinterColumns:
        - name: Size
          type: integer
          jsonPath: .spec.size
```

Apply it and check that the API server knows the new kind:

```sh
kubectl apply -f crd-bays.yaml
kubectl api-resources --api-group=fleet.example.com
```

The list shows `bays` in the group `fleet.example.com`. Create one object of the new kind. Save this as `bay-alpha.yaml`:

```yaml
apiVersion: fleet.example.com/v1
kind: Bay
metadata:
  name: alpha
  namespace: starfleet
spec:
  size: 3
```

Apply it and read it back:

```sh
kubectl apply -f bay-alpha.yaml
kubectl -n starfleet get bays
```

The table shows the `alpha` object with the size column. Now set `size` to `20` in the file and apply it again. The API server rejects the request because the schema allows at most `10`. Validation belongs to the CRD, so a wrong value never reaches a controller.

## What is missing

The object exists and nothing happens. The cluster has no controller for `Bay`, and no `status` ever appears. This is the point of the exercise. A custom resource is data. The behaviour comes from a controller that someone installs. Crossplane installs generic controllers for cloud providers and lets you combine managed resources into your own kinds. Cluster API installs controllers that create Kubernetes clusters from `Cluster` and `Machine` objects.

Because the objects are plain manifests, the tools from the configuration modules apply: Git for history, `kubectl diff` for review, server-side apply for ownership and a GitOps agent for continuous delivery. The control plane approach and the OpenTofu approach do not exclude each other. Some teams run OpenTofu to create the first cluster and then use controllers for everything inside it.

You now know where infrastructure can be declared. The last part covers the habits that make every such change safe to review.

## Common pitfalls

> [!WARNING]
> - Deleting a CRD deletes every object of that kind. If a controller manages cloud resources from those objects, the cloud resources may be deleted too.
> - An accepted custom resource does not mean that anything was created. Read the `status` and the controller logs.
> - A controller needs credentials for the cloud API. Give it only the rights its kinds need.
> - Keep the CRD and the controller on matching versions. A new field in the CRD does nothing if the controller does not know it.
