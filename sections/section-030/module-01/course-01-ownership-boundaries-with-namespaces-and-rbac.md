---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Ownership Boundaries With Namespaces And RBAC

A platform only helps when it states who owns what. If the application team has no access, every change becomes a ticket and the team waits. If the team has cluster administrator access, one mistake or one stolen credential can affect every other team. DevOps asks for a middle path: the team receives exactly the access that its work needs, in the place where its work happens. In Kubernetes that place is a namespace and the mechanism is role-based access control (RBAC).

## What RBAC is and which component enforces it

RBAC is the authorisation mode of the Kubernetes API server. Every request to the API server has an identity, a verb, a resource type and a namespace. The API server checks the request against the Role and RoleBinding objects it stores. If a rule allows it, the request goes on. If no rule allows it, the API server answers `Forbidden`. There are no deny rules: access is the union of everything that is granted.

A ServiceAccount is the identity inside the cluster. Its full name is `system:serviceaccount:<namespace>:<name>`. A Role lists rules. Each rule names API groups, resource types and verbs such as `get`, `list`, `watch`, `create`, `update`, `patch` and `delete`. A RoleBinding connects a Role to subjects, which are the identities that receive it. A Role and its RoleBinding apply only inside their own namespace. A ClusterRole and ClusterRoleBinding apply to the whole cluster, and a team should rarely receive those.

## Build the identity of the application team

You act as the platform team now. The team that owns `scout` needs an identity. Save this as `scout-team.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: scout-team
  namespace: starfleet
  labels:
    owner: application-team
```

Apply it:

```sh
kubectl apply -f scout-team.yaml
```

The identity exists and can do nothing yet. Ask the API server directly. The command `kubectl auth can-i` sends an authorisation question and prints `yes` or `no`. With `--as` it asks on behalf of another identity, which only an administrator may do:

```sh
kubectl auth can-i get pods -n starfleet --as=system:serviceaccount:starfleet:scout-team
```

The answer is `no`. A new ServiceAccount has no permission beyond what every authenticated identity receives. Remember this habit: test the access before you hand it over.

## Write a role that matches the work

List what the team does. It creates and updates Deployments, reads pods and pod logs to find problems, and reads Services. It does not delete Deployments in production, read Secrets, change access rules or touch other namespaces. Save this as `scout-deployer.yaml`:

```yaml
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

An empty string in `apiGroups` means the core API group, which holds pods and Services. Deployments belong to the `apps` group. The subresource `pods/log` is named separately, because reading logs is a different permission from reading the pod object. Apply it:

```sh
kubectl apply -f scout-deployer.yaml
```

## Prove the boundary

Run a set of questions. The first three should answer `yes`, and the rest should answer `no`:

```sh
kubectl auth can-i patch deployments -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i get pods --subresource=log -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i create deployments -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i delete deployments -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout-team
kubectl auth can-i patch deployments -n outpost --as=system:serviceaccount:starfleet:scout-team
```

The last answer shows the namespace boundary. The binding exists only in `starfleet`, so the same identity has no rights in `outpost`. The `delete` answer shows that the team can ship and change, and a deletion needs the platform team or a reviewed process. That is a design decision, and the team can ask to change it.

## Read the feedback of a denial

Try a real request as the application team. Deleting is not allowed, so use it:

```sh
kubectl -n starfleet delete deployment probe --as=system:serviceaccount:starfleet:scout-team
```

The API server refuses and prints a `Forbidden` error. The message names the identity, the verb, the resource and the namespace. That is actionable feedback. The developer can see exactly which permission is missing, and the platform team can decide whether to grant it. A denial that says only "access denied" forces a guess. Notice also what stayed safe: the `probe` Deployment still exists, because the check happens before any change.

The ownership split in this setup is now concrete. The platform team owns the namespace, the identity, the Role and the binding. The application team owns what it deploys inside. Each side can see what the other offers: the application team reads its own permissions with `kubectl auth can-i --list`, and the platform team reads who has access with `kubectl get rolebindings`. Access is only one limit, though. A team with the right to create Deployments can still consume all the memory of the cluster, and the next part covers that.

## Common pitfalls

> [!WARNING]
> - Do not give a team a ClusterRole or the `cluster-admin` role to avoid writing rules. One mistake or leaked token then reaches every namespace.
> - A Role that uses `*` for verbs or resources grants more than you read at first. List the exact verbs and resources.
> - Reading Secrets is a separate permission from reading Deployments. Check it, because anyone who can read a Secret can read its value.
> - A RoleBinding lives in one namespace. A rule that works in `starfleet` gives nothing in `outpost`.
