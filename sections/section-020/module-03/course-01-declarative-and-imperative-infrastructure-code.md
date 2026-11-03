---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Declarative And Imperative Infrastructure Code

Every infrastructure tool must answer one question: does the author write the steps, or the result? The answer changes how the code behaves when it runs a second time, when it runs half way, and when someone changed the system by hand in between. This part defines the two styles, shows the difference with a small example and places the common tools on the map.

## Two styles

An imperative script lists steps in order: create a network, create a server, attach a disk. The tool does exactly those steps, in that order. A declarative configuration states the result: a network with this address range, a server of this size attached to it. The tool reads the current state, compares it with the description and works out which steps are needed.

Shell scripts, and the command lines of cloud providers, are imperative. OpenTofu and Terraform (declarative HashiCorp Configuration Language, HCL), AWS CloudFormation, Azure Bicep and Kubernetes manifests are declarative. Pulumi uses general programming languages such as Python or Go, but the program still describes resources and the Pulumi engine computes the changes, so its model is declarative. Ansible uses YAML playbooks that run tasks in order, and each task is written to be idempotent, so it sits between the two styles. Crossplane and Cluster API are declarative and run inside Kubernetes.

## Idempotence in a script

A step is idempotent when running it again leaves the same result. Make a directory twice from a shell:

```sh
mkdir roster
mkdir roster
```

The second command fails because the directory exists. The script has to guard every step with a check, and a long script becomes a list of guards. Remove the directory and use the flag that makes the step idempotent:

```sh
rmdir roster
mkdir -p roster
mkdir -p roster
```

Both runs succeed. A declarative tool gives you this behaviour for every resource without writing the guard.

## Idempotence in OpenTofu

OpenTofu is the open source fork of Terraform. It reads `.tf` files, keeps a state file that records the objects it manages and compares the three: the files, the state and the real objects. Make an empty directory and save this as `main.tf`:

<!-- astrona:playground:renew -->

```hcl
terraform {
  required_version = ">= 1.6.0"
}

resource "terraform_data" "crew_roster" {
  input = "night-shift"
}

output "roster" {
  value = terraform_data.crew_roster.output
}
```

The resource `terraform_data` is built into OpenTofu. It stores a value in the state and needs no provider, so it shows the workflow without a cloud account. Initialise the directory and apply:

```sh
tofu init
tofu apply -auto-approve
```

The first apply creates one resource. Apply again:

```sh
tofu apply -auto-approve
```

The tool reports that no changes are needed and that the infrastructure matches the configuration. Change `night-shift` to `day-shift` and apply a third time. The plan shows an update of the one value, and nothing else is touched. The tool did the work of finding the difference.

## Which style to choose

Declarative code suits the stable shape of infrastructure: the objects that must exist. It is easy to review, because the file is the answer. Procedural steps suit one-off work with order: a database migration, a package install on a machine that already exists, a rolling restart. Many teams use both. They provision with a declarative tool and configure the machines with a procedural one.

Declarative tools have limits. Logic such as loops and conditions makes the files harder to read, and a tool can only manage what its providers support. The state file is a second source of truth that must be kept safe, which the last part of this module covers.

You now have the vocabulary. The next part asks what the tool should do when a running resource needs a change: change it in place, or replace it.

## Common pitfalls

> [!WARNING]
> - "Declarative" describes the model and not the file format. A YAML file of commands is not declarative.
> - A script that works on the first run can fail on the second. Test infrastructure code by running it twice.
> - Do not edit the state file by hand. Use the tool's own state commands.
> - A plan of "no changes" means the state, the code and the real objects agree. It does not mean the code is correct.
