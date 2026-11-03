---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Security Checks In The Delivery Path

DevSecOps adds security to the same shared, automated path that DevOps uses for delivery. Instead of one security review at the end, small checks run at each step, so a problem is found where it is cheap to fix. This module puts two such checks on a real path in Kubernetes: the Pod Security Admission check that the cluster runs for every pod, and a deployment identity that has only the rights that a deployment needs.

You work with a Deployment `scout` that runs as root with a privileged container. You enforce a security standard on its namespace, watch the cluster refuse a pod, fix the pod specification and then restrict the identity that deploys it.

## Learning Goals

- Explain DevSecOps as security checks inside the delivery path, and name what each check can and cannot prove.
- Describe Pod Security Admission, its three modes and the Pod Security Standards levels.
- Fix a pod specification so that it passes the `restricted` level, using a security context.
- Use `kubectl apply --dry-run=server` as a check before a change reaches the cluster.
- Create a deployment identity with least privilege and keep secrets out of files and pods that do not need them.

## Before You Start

You should know what a namespace, a pod, a Deployment and a ServiceAccount are, and how to apply a manifest with `kubectl`. The hands-on parts use a playground with a kind cluster and `kubectl`. Each technical term is defined where it first appears.

## What You Work With

The playground starts a single-node kind cluster with Kubernetes 1.35. It contains the namespace `dockyard` with a Deployment `scout` of two replicas. The pods run the podinfo image as the root user, with a privileged container. No security rule has been set on the namespace yet.

| Namespace | Object | Role |
| --- | --- | --- |
| `dockyard` | `scout` | A Deployment with an unsafe pod specification that you improve. |
| `dockyard` | `scout-token` | A Secret that the application reads. |

## The Words This Module Uses

- **Pod Security Admission**: a check built into the API server that accepts or refuses pods, based on labels on the namespace.
- **Pod Security Standards**: three named levels of pod restrictions: `privileged`, `baseline` and `restricted`.
- **Security context**: the fields of a pod or container that set the user, the Linux capabilities and other privileges.
- **Dry run**: a request that the API server processes fully but does not store.
- **Least privilege**: giving an identity only the permissions that its task needs.
- **Secret**: an object that holds sensitive data, such as a token, stored base64 encoded and not encrypted by default.

## What You Can Do At The End

You can turn on a security standard for a namespace in a way that warns first and enforces later. You can read the refusal message for a pod, change the specification until it passes and prove that the change works without creating the pod. You can give a deployment identity the rights for one Deployment and prove that it has no others.

## Failure Cases This Module Covers

- A Deployment that runs fine until the namespace enforces a standard, and then cannot create a new pod.
- A `runAsNonRoot` setting on an image whose user is not a number.
- A deployment identity with cluster-wide rights, so that one leaked token reaches every namespace.
- A Secret that is mounted into a pod that does not need it.

## Reading Order

1. Pod Security Admission And Security Contexts: refusing and repairing unsafe pods.
2. Least-Privilege Deployment Identities And Secrets: what the deployer may do and what stays hidden.
3. Summary

<!-- astrona:playground -->
