---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Reviewing, Testing And Securing Infrastructure Changes

Infrastructure code can delete a database with one line, so it needs more care than application code. The usual safeguards are a fixed order of checks, a plan that a person reads, and a careful place for the state file. This part runs the checks with OpenTofu and then looks at what the state file contains.

## A sequence of checks

A pipeline for infrastructure code runs cheap checks first and expensive ones later. Format check, validation and plan run on every pull request. Apply runs only after the pull request is merged, and only in the pipeline, so one controlled identity holds the credentials. Reuse the directory from the first part and run the first two checks:

<!-- astrona:playground:renew -->

```sh
tofu fmt -check
tofu validate
```

`tofu fmt -check` exits with a non-zero code when a file is not in the canonical format and lists the files that need changes. `tofu validate` checks that the configuration is valid on its own: the syntax, the names of arguments and the references between resources. It does not look at real infrastructure.

## Save and read a plan

A plan shows what an apply would do. Save it to a file, so that the apply runs exactly what was reviewed:

```sh
tofu plan -out=review.tfplan
tofu show review.tfplan
```

The `show` command prints the saved plan in readable form. Add `-json` and pipe the output to `jq` to let a policy check read it. Then apply the same file:

```sh
tofu apply review.tfplan
```

This order matters. A plan made at review time can be out of date by the time of the apply, so the apply of a saved plan fails if the state changed in between, and nobody applies something that nobody saw.

## Policy checks

Policy as code tools read the plan or the files and reject changes that break a rule: a storage bucket that is public, a security group that is open to the world, a resource without an owner tag. Common tools are TFLint for style and provider-specific errors, Checkov and Trivy for security rules, and Open Policy Agent with Conftest for rules that you write yourself. They run in the same pipeline stage as the plan.

## What the state file holds

The state file records every attribute of every resource, including values that the code marked as secret. Prove it with a sensitive variable. Add this to `main.tf`:

```hcl
variable "api_token" {
  type      = string
  sensitive = true
  default   = "ensign-7f3a91"
}

resource "terraform_data" "credentials" {
  input = var.api_token
}
```

Apply and search the state:

```sh
tofu apply -auto-approve
grep ensign terraform.tfstate
```

The `sensitive` flag hides the value in the terminal output. The state file still holds it in plain text. Three rules follow. Store the state in a remote backend that is encrypted and access controlled, for example an object store with versioning, and not in Git. Use locking so that two runs cannot write the state at the same time. Keep real secrets in a secret manager and read them at run time. OpenTofu can also encrypt the state itself with an `encryption` block, and teams that cannot avoid secrets in state should enable it.

## Least privilege for the pipeline

The identity that applies infrastructure code can create and delete resources, so it is a high value target. Give it only the rights that the code needs, short-lived credentials where the platform supports them and a separate identity for each environment. Run a scheduled `tofu plan -detailed-exitcode` to find drift: exit code 2 means there is a difference.

Together these steps form the safe path of an infrastructure change: write, format, validate, plan, review, apply from the pipeline and watch for drift. The summary collects the points of the module.

## Common pitfalls

> [!WARNING]
> - Do not commit `terraform.tfstate` to Git. It can hold secrets and it changes on every apply.
> - `sensitive = true` hides a value from output and not from the state file.
> - A plan is only a prediction. If someone changes the infrastructure between the plan and the apply, apply the saved plan or plan again.
> - Do not give the pipeline administrator rights on the whole account. A mistake or a stolen token then reaches everything.
