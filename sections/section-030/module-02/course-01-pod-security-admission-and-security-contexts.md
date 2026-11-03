---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Pod Security Admission And Security Contexts

A pod that runs as root with extra Linux privileges gives an attacker who breaks into the application a much stronger position on the node. A review at the end of a project may never see that detail, because it hides in one YAML field. The cluster can check every pod itself, at the moment the pod is created, and refuse the dangerous ones. This part turns that check on, watches it refuse a pod and repairs the pod specification.

## The check and where it runs

Pod Security Admission is a controller inside the API server. When a request creates or updates a pod, the controller reads labels on the namespace and compares the pod specification with a level of the Pod Security Standards. The levels are `privileged` (no restrictions), `baseline` (blocks the known dangerous settings, such as privileged containers and host namespaces) and `restricted` (follows current hardening practice for pods, for example no running as root, no privilege escalation, all capabilities dropped and a seccomp profile set).

A namespace label chooses a mode for a level. The mode `enforce` rejects violating pods. The mode `warn` accepts them and returns a warning to the user. The mode `audit` accepts them and records the violation in the audit log. A team can start with `warn` to learn what would break and move to `enforce` later. The labels have the form `pod-security.kubernetes.io/<mode>: <level>`.

One detail matters for Deployments. The check runs on pods, and a Deployment creates pods through a ReplicaSet. The API server accepts a Deployment that would produce a violating pod. The ReplicaSet controller then fails to create the pod, and the evidence is in events. Kubernetes gives a warning at the Deployment for the `warn` and `audit` modes, but the `enforce` mode is visible in the events of the ReplicaSet.

## The starting state

The playground contains the namespace `dockyard` with the Deployment `scout`. Look at the container security context, which is the field that sets privileges:

<!-- astrona:playground:renew -->

```sh
kubectl -n dockyard get deployment scout -o jsonpath='{.spec.template.spec.containers[0].securityContext}{"\n"}'
kubectl -n dockyard get pods
```

The context contains `privileged` set to true, and two pods are running. The namespace has no Pod Security labels, so nothing checks the pods. Ask what a stricter level would say about the namespace before you change anything. A server-side dry run of a label change reports the pods that would violate the level:

```sh
kubectl label --dry-run=server --overwrite namespace dockyard pod-security.kubernetes.io/enforce=restricted
```

The command does not store the label. The API server answers with warnings that list the pods of `scout` that would violate the level and the reasons, such as privileged containers, a missing `allowPrivilegeEscalation` setting and a missing seccomp profile. The existing pods keep running, because the label applies to new pods. This dry-run is a useful check in a pipeline: it shows the impact of a policy before the policy applies.

## Turn the standard on

Set the level to `restricted` and enforce it:

```sh
kubectl label --overwrite namespace dockyard pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/warn=restricted
```

Nothing visible happens yet, because the two running pods stay. Force the creation of new pods with a restart, which is a normal event during a release:

```sh
kubectl -n dockyard rollout restart deployment/scout
kubectl -n dockyard get pods
kubectl -n dockyard get events --field-selector reason=FailedCreate
```

The new pods do not appear. The Deployment keeps its old pods running while the new ReplicaSet fails to create any. The `FailedCreate` event names the violations, one per setting. This is the failure case that surprises teams: an unsafe Deployment works for months, and a routine restart breaks it after a policy change. The old pods are not at risk of being killed, and the rollout stalls without taking the old pods away because the rolling update waits for the new pods to become ready.

## Repair the pod specification

Each violation maps to one security context field. Save this as `scout-restricted.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: dockyard
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
          securityContext:
            runAsUser: 10001
            allowPrivilegeEscalation: false
            privileged: false
            capabilities:
              drop: ["ALL"]
```

Read each field. `runAsNonRoot: true` makes the kubelet refuse to start a container that would run as user 0. The `runAsUser: 10001` line sets a numeric user, because the kubelet can only verify `runAsNonRoot` when the user is a number, and some images name their user. `allowPrivilegeEscalation: false` stops a process from gaining more privileges than its parent. `capabilities.drop: ["ALL"]` removes all Linux capabilities, which are fine-grained pieces of the root user's power. `seccompProfile: RuntimeDefault` applies the container runtime's default filter on system calls.

Before you apply it, run the check that a pipeline would run. A server-side dry run sends the request through authentication, authorisation, admission and validation, and stores nothing:

```sh
kubectl apply --dry-run=server -f scout-restricted.yaml
```

The command succeeds and prints that the Deployment is configured, with no warning about Pod Security. A violation would show a warning, because the `warn` mode is on. Apply it for real and wait for the rollout:

```sh
kubectl apply -f scout-restricted.yaml
kubectl -n dockyard rollout status deployment/scout
kubectl -n dockyard get pods
```

The new pods start, the old ones go away and no `FailedCreate` events appear for the new ReplicaSet. The pods run as the user 10001.

The cluster now refuses unsafe pods without a person in the loop, and the developer sees the reason in the same tools used for any other failure. The check proves one thing: the pod specification meets a standard. It does not prove that the application code is free of flaws, or that the image has no known vulnerable packages. Those need other checks on other steps of the path. The next part addresses the identity that performs the deployment and the secrets it can reach.

## Common pitfalls

> [!WARNING]
> - The check applies to new pods only. Pods that already run keep running until something replaces them, so the first restart after a policy change can fail.
> - `runAsNonRoot` alone is not enough when the image user is a name. Set a numeric `runAsUser`.
> - `restricted` needs several fields together. Fixing one violation shows the next one in the message.
> - Use `warn` and `audit` first on a namespace with many workloads. Move to `enforce` after the warnings stop.
