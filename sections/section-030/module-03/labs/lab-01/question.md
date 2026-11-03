# Question

Solve this question on: `terminal`

The namespace `ops` holds the Deployments `scout` (two replicas) and `probe` (one replica). An alert fired last night and nobody knew who owned `probe` or where its runbook was. The platform team wants every workload to carry ownership data and the delivery history to explain each change.

1. Label both Deployments with `app.kubernetes.io/part-of: starfleet`. Label `scout` with `owner: scout-team` and `probe` with `owner: probe-team`.

2. Annotate each Deployment with `runbook` and the value `runbooks/<name>.md`, where `<name>` is the Deployment name.

3. Make one change to the pod template of `scout`, for example the environment variable `PODINFO_UI_MESSAGE`, and record the reason in the annotation `kubernetes.io/change-cause`. The history of `scout` must then show at least two revisions, and the newest one must have a change cause.

4. Check that `kubectl -n ops get deployments -l owner=scout-team` lists only `scout`, and that both Deployments stay available.

`kubectl` already points at the cluster as the cluster administrator.
