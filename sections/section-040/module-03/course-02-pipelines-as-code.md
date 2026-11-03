---
draft: true
exam_objectives:
- CI and CD
---
# Pipelines As Code

A pipeline that is configured by clicking in a web page cannot be reviewed, copied or recovered. Modern CI/CD systems store the pipeline definition as a file in the repository, next to the code it builds. This is the same idea as Configuration as Code, applied to the delivery path. This part shows what such a file contains and demonstrates that one pipeline step is a container with an exit code.

## What a pipeline file contains

Every common system has the same building blocks under different names. A **trigger** says when the pipeline runs: on a push, on a pull request, on a tag or on a schedule. A **job** is a unit of work that runs on one **runner**, the machine or container that executes it. A **step** is one command or action inside a job. **Artifacts** are files that one job saves for another. A **cache** keeps downloaded dependencies between runs to save time. **Secrets** are values that the system injects at run time and hides in logs. An **environment** is a named target such as `production`, which can require an approval before a job runs.

Here is a workflow file for GitHub Actions, shown for reading, with two jobs. The second job waits for the first:

```yaml
name: build-and-test
on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: make test
  publish:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: make image
```

GitLab CI uses a `.gitlab-ci.yml` file with `stages` and jobs. Jenkins uses a `Jenkinsfile` written in a Groovy-based language. Tekton defines `Task` and `Pipeline` objects that run as pods inside a Kubernetes cluster. The vocabulary changes, and the structure does not.

## A step is a container with an exit code

In Tekton, in GitLab runners with Kubernetes and in many other systems, a step is a container. A step passes when the main process exits with code 0 and fails otherwise. You can see this with a Kubernetes Job, which runs a pod to completion. Save this as `job-test-pass.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: test-pass
  namespace: launch
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: test
          image: busybox:1.37
          command: ["sh", "-c", "echo running tests; exit 0"]
```

Apply it and wait for the result:

```sh
kubectl apply -f job-test-pass.yaml
kubectl -n launch wait --for=condition=complete job/test-pass --timeout=120s
kubectl -n launch logs job/test-pass
```

The wait returns when the Job is complete, and the log shows the output of the step. Now change the file: set the name to `test-fail` and the command to `echo running tests; exit 1`. Apply it and check:

```sh
kubectl -n launch get job test-fail -o jsonpath='{.status.conditions[*].type}{"\n"}'
```

The Job reports the condition `Failed`. The value `backoffLimit: 0` told Kubernetes not to retry. A pipeline engine builds on the same fact: it reads the result, stops the later jobs and reports the failure.

## Practices for pipeline code

Pin the version of every action and base image, since a moving reference can change what the pipeline does between two runs. Give each job only the permissions it needs, for example read access to the repository and no access to production. Keep secrets in the system's secret store and never echo them. Use environments with approval for production jobs. Keep the file short by moving shared steps into reusable workflows or templates, and review changes to the pipeline file as carefully as changes to the code, because a modified pipeline can send secrets anywhere.

The pipeline definition is also a target: a pull request from an untrusted fork must not run with secrets. Systems offer settings that run such pull requests without secrets, and teams should keep them on.

You now know what a pipeline file is made of. The next part looks at the last stage, which has several different shapes: how a new version replaces the old one.

## Common pitfalls

> [!WARNING]
> - Do not reference an action or image by a moving tag such as `latest`. Pin a version or a digest.
> - A job with the default broad token can write to the repository. Reduce the permissions of each job.
> - A pull request from a fork must not receive secrets.
> - A Job in Kubernetes retries by default. Set `backoffLimit` when a failure must stop at once.
