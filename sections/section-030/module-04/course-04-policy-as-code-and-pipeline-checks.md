---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# Policy As Code And Pipeline Checks

An admission policy rejects a bad change at the last moment, when the author has left the pull request and is waiting for a deployment. It is cheaper to catch the same problem earlier. Policy as code means that the rules are files in version control, run by tools in several places, so that the author sees the same answer in the editor, in the pull request and at the cluster. This part lays out where each check belongs.

## The stages of a secure path

A change travels through stages, and each stage has checks that suit it.

1. **On the developer machine.** A pre-commit hook scans for secrets such as tokens and keys, with a tool like Gitleaks. The check is fast and stops the secret before it enters the history.
2. **In the pull request.** Linters and validators read the manifests. `kubeconform` checks them against the Kubernetes schemas, `kube-linter` checks for risky settings, and Conftest runs rules written in the Rego language against any file. Dependency scanning and static code analysis also run here.
3. **In the build.** The build produces the image, generates an SBOM, scans the image with Trivy or Grype and signs it with cosign. It records provenance.
4. **Before deployment.** A server-side dry run sends the final manifests through the real admission chain of the target cluster.
5. **At the cluster.** Admission policy and Pod Security Admission enforce the rules for everything, including changes that did not come from the pipeline.
6. **At run time.** Monitoring and runtime detection watch for behaviour that no earlier check could predict.

The same rule can appear twice. A lint rule in the pull request gives fast, friendly feedback. The admission rule is the guarantee, because it cannot be skipped.

## A dry run as a pipeline step

A server-side dry run needs only `kubectl` and a cluster credential with limited rights. Save a manifest that breaks the rule from the previous part as `deployment-latest.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-latest
  namespace: dock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe-latest
  template:
    metadata:
      labels:
        app: probe-latest
    spec:
      containers:
        - name: probe
          image: ghcr.io/stefanprodan/podinfo:latest
```

Run the dry run and print the exit code:

```sh
kubectl apply --dry-run=server -f deployment-latest.yaml
echo $?
```

The command prints the message of the policy, and the exit code is not zero. A pipeline stops at a non-zero code, so the author reads the message in the pull request check. Change the image to `ghcr.io/stefanprodan/podinfo:6.15.0` and run it again. The command succeeds with exit code 0 and stores nothing.

## Make the feedback actionable

A check that says only "policy violation" costs the author time. Write the `message` of each validation so that it states the rule and the fix, as the message in the policy of this module does. Show which object and which field failed. A check that fails with a clear message is fixed in minutes. A check that is vague gets disabled.

## Treat policies like code

Policies live in Git, go through review and have tests. A test for the policy above is a pair of manifests, one that must pass and one that must fail, run in the pipeline. Roll a new policy out in stages: warn, then deny in a test namespace, then deny everywhere. Keep a documented way to request an exception, since a rule with no exception path gets bypassed, and record each exception with an owner and an end date.

## Secrets in the path

Secrets need their own care. Keep them out of Git, out of images and out of build logs. Give the pipeline short-lived credentials from the platform, such as a token issued for one run, in place of a stored password. Scan the history of a repository when a secret may have leaked, and rotate any secret that was committed, because deleting the file does not remove it from the history.

## Where the checks stop

Checks reduce risk and do not remove it. A new vulnerability, a stolen credential or a mistake in a rule can pass every stage. DevSecOps accepts this and adds detection and recovery to prevention: monitoring, a fast rollback and a practised response.

## Common pitfalls

> [!WARNING]
> - A check that runs only in the pipeline can be bypassed by someone with `kubectl` access. Keep the admission policy as the last guarantee.
> - Do not scan an image and deploy a different tag. Scan, sign and deploy the same digest.
> - A rule that nobody can get an exception for will be turned off. Provide a short, recorded exception path.
> - A dry run needs the same admission setup as the target cluster. A dry run against a different cluster proves little.
