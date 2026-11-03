---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Supported Limits And Actionable Feedback

Access rules decide who may create an object. They do not decide how much the object may use. A team with the right to create Deployments can still start so many pods that other teams in the same cluster run out of memory. A platform that offers shared capacity must say how much each team may use and must tell the team clearly when it reaches the limit. This part builds the limits and then triggers them, because the message a developer sees is part of the platform.

## Two objects, two jobs

A ResourceQuota sets a ceiling for a whole namespace. It can limit the number of objects, such as `pods`, and the sum of resource requests and limits, such as `requests.cpu` and `requests.memory`. A resource request is the amount of CPU or memory that the scheduler reserves for a container when it places the pod on a node. A limit is the maximum that the container may use.

A LimitRange works on single containers and pods. It can set a default request and default limit for containers that declare none, and a minimum and maximum for those that do. Both objects are enforced by the API server at admission time. Admission is the step after authorisation in which the API server can change or reject a request before it stores the object. The LimitRange admission step runs first and fills in defaults. The quota check then adds the numbers up and refuses the request if the sum exceeds the ceiling.

The two objects work together for a practical reason. When a namespace has a quota on `requests.cpu`, every new pod must declare a CPU request, or the API server rejects it. Without a default, a developer has to know and add that field. With a LimitRange default, the pod is accepted and receives the default.

## Declare the platform limits

Save this as `team-limits.yaml`:

<!-- astrona:playground:renew -->

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

The value `500m` means 500 millicores, which is half of one CPU core. The playground already runs four pods in the namespace (two `scout`, one `probe` and one `shuttle`), so a ceiling of six pods leaves room for two more. Apply it:

```sh
kubectl apply -f team-limits.yaml
```

Read the quota. The command shows each limit next to the amount that is already used:

```sh
kubectl -n starfleet describe resourcequota team-quota
```

The `Used` column shows four pods and the sum of the requests of the existing containers. The quota controller, a component of the controller manager, recalculates these numbers when objects change. The platform team can use this view to see how close the team is to the ceiling before the team hits it.

## See the defaults at work

Create a pod that declares no resources. Save this as `plain-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: plain
  namespace: starfleet
  labels:
    app: plain
spec:
  containers:
    - name: plain
      image: curlimages/curl:8.22.0
      command: ["sh", "-c", "sleep 3600"]
```

Apply it and read what the API server stored:

```sh
kubectl apply -f plain-pod.yaml
kubectl -n starfleet get pod plain -o jsonpath='{.spec.containers[0].resources}{"\n"}'
```

The manifest has no `resources` field, and the stored pod has requests of `50m` CPU and `64Mi` memory and a memory limit of `128Mi`. The LimitRange admission step added them. The quota check then counted those requests. This is a small example of a supported default: the platform removes a field that the team would otherwise have to know.

## Trigger the ceiling and read the message

Now ask for more than the namespace allows. The quota allows six pods and five exist. Scale `scout` from two to five replicas, which asks for three more pods:

```sh
kubectl -n starfleet scale deployment scout --replicas=5
kubectl -n starfleet get deployment scout
kubectl -n starfleet get events --field-selector reason=FailedCreate
```

The scale command is accepted, because it only changes a number in the Deployment. The Deployment shows fewer ready pods than desired. The ReplicaSet controller tries to create the pods, and the API server refuses the ones above the ceiling. The refusal appears as `FailedCreate` events on the ReplicaSet. Each event message says that the pod is forbidden because the quota `team-quota` is exceeded, and it names what was requested, what is used and what the limit is.

This is the point where feedback matters. The developer ran a command that looked successful, and the problem appears later in an event. A platform that wants fast feedback must teach where to look and what the words mean. Three habits help: read the Deployment status, read the events of the ReplicaSet, and read the quota with `describe`. The message also tells the developer who can act. A quota ceiling is a platform decision, so the developer asks the platform team to raise it or removes other workloads. Return `scout` to two replicas and delete the test pod:

```sh
kubectl -n starfleet scale deployment scout --replicas=2
kubectl -n starfleet delete pod plain
```

## Labels make ownership visible

A limit only helps when someone knows who owns a workload. A label such as `owner` on every object answers the question "who do I ask?" during an incident. A platform can require the label and can show it in listings. Add it to the `scout` Deployment and list the Deployments with the label as a column:

```sh
kubectl -n starfleet label deployment scout owner=application-team
kubectl -n starfleet get deployments -L owner
```

The `-L` flag adds a column for the label. Deployments without the label show an empty value, which is a visible gap that a review can close.

Both sides of a platform contract are now visible: access in the form of Roles, and capacity in the form of quotas and defaults. In both cases the system did the checking, and the message explained the refusal. What remains open is how security checks fit into the same path, which is a question about what the platform may refuse before an application runs at all.

## Common pitfalls

> [!WARNING]
> - A quota on `requests.cpu` rejects pods that declare no CPU request unless a LimitRange default exists. Add the default or the deployment fails with a message about missing requests.
> - A quota does not stop a scale command. The Deployment accepts the number, and the pods fail later with `FailedCreate` events.
> - Do not set a quota so low that a rolling update cannot create its extra pods. The update stalls.
> - Do not hide the limits. A team that cannot read its own quota with `kubectl describe` cannot explain a refusal.
