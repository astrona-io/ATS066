---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Reading Plans, Replacement And Lifecycle Rules

A source diff of one line can hide a large change in the real system. Changing the name of a database in a file looks like a rename, but the provider may treat it as "delete the database and create an empty one". The only place where this is visible before it happens is the plan. This part teaches how to read a plan, how to freeze a reviewed plan and how to stop a dangerous action with a lifecycle rule.

## What a plan is made of

When you run `tofu plan`, OpenTofu does three things in order. It reads the state file to learn which objects it owns. It asks the provider to read each of those objects from the API, which is called a refresh. Then it compares the refreshed values with the values in your files and builds a list of actions. The plan is that list. It is a proposal made at one moment, and it does not lock the cluster.

Each resource in the plan starts with a symbol that names the action:

| Symbol | Action | Meaning |
| --- | --- | --- |
| `+` | create | The object does not exist yet. |
| `~` | update in place | The provider edits the object and keeps its identity. |
| `-` | destroy | The provider deletes the object. |
| `-/+` | replace | The provider deletes the object and creates a new one. |

Inside an updated resource, a line with `~` shows an old value and a new value. A value that is only known after the apply is printed as `(known after apply)`. When a change forces a replacement, OpenTofu adds the words `# forces replacement` next to the field that caused it. A reviewer looks for these words first.

## Why some changes replace the object

Whether a field can be edited depends on the API of the real system, and the provider records it for every field. The Kubernetes API allows an edit of the data of a ConfigMap, so the provider updates it. The API does not allow a rename. An object name is its identity, so a new name means a different object. The provider marks the name field as one that forces a replacement.

Try it in the working directory that holds `versions.tf`, `namespace.tf` (the namespace `hangar` with the label `managed-by`) and `workload.tf` (the ConfigMap `hangar-settings` and the Deployment `beacon`), all applied. If you start with an empty directory, write those three files and run `tofu init` and `tofu apply` first. In `workload.tf`, change the ConfigMap name from `hangar-settings` to `hangar-config`, and run the plan.

<!-- astrona:playground:renew -->

```sh
tofu plan
```

The plan shows the ConfigMap with `-/+` and `# forces replacement` on the `name` line. The Deployment also appears with a change, because it refers to the ConfigMap name, and that name is a value that changes. Nothing has happened to the cluster yet. Do not apply this plan. Change the name back to `hangar-settings` and run `tofu plan` again. It reports that the infrastructure matches the configuration and that no changes are needed.

A replacement is harmless for a ConfigMap that can be recreated from the file. It is serious for a namespace, because deleting a namespace deletes every object inside it, and for a volume claim, because the data goes with it. The plan text is the same for all of them. The reviewer must know what the object holds, which the plan cannot say.

## Save the plan and apply that plan

A plain `tofu apply` plans again and then applies the new plan. If the cluster or the files changed between the review and the apply, the applied actions differ from the ones the reviewer saw. A saved plan removes the gap. Write the plan to a file:

```sh
tofu plan -out=tfplan
```

Change `mode` to a new value first if you want a visible difference. Then apply the saved plan:

```sh
tofu apply tfplan
```

With a plan file, `tofu apply` does not ask for confirmation, because the plan was already reviewed. It runs exactly the saved actions. If the state changed after the plan was saved, OpenTofu refuses to apply the stale plan and asks for a new one. Do not name the file with the suffix `.tf`, because OpenTofu would read it as configuration, and treat the file as sensitive, because it can contain values in plain text.

Automation uses this pair of commands. A pipeline job runs `tofu plan -out=tfplan` and stores the plan for review. A later job applies that same file after approval. The plan file is the artifact that carries the approval.

## Stopping a dangerous action

A lifecycle rule is a setting inside a resource block that changes how OpenTofu treats the resource. Add this rule to the namespace in `namespace.tf`:

```hcl
resource "kubernetes_namespace_v1" "hangar" {
  metadata {
    name = "hangar"
    labels = {
      "managed-by" = "opentofu"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

With `prevent_destroy = true`, any plan that would destroy this resource stops with an error. Check it by changing the namespace name to `hangar-two` and running the plan:

```sh
tofu plan
```

The plan fails with an error that says the resource cannot be destroyed, and no plan is produced. A rename would have deleted the namespace, so the rule caught it. Change the name back to `hangar`.

Two limits matter. The rule only lives in the files. If you delete the whole resource block, the rule is gone as well, and the next plan proposes the destroy without an error. And the rule does not stop `kubectl delete namespace hangar`, because that command never goes through OpenTofu. The tool then finds the object missing at the next refresh and proposes to create it again, with no data inside. Other lifecycle settings exist. `create_before_destroy` creates the new object before it removes the old one, and `ignore_changes` makes OpenTofu ignore the listed fields, for example fields that another controller edits.

## Destroying on purpose

`tofu destroy` plans the removal of everything in the state and then deletes it. It is the correct way to remove an environment that OpenTofu created, because it removes the objects in reverse dependency order. Remove the lifecycle rule first, since it would block the plan, and review the plan:

```sh
tofu plan -destroy
```

The plan shows every resource with a minus sign and the summary line shows the number to destroy. If the plan is right, run `tofu destroy`, type `yes`, and check that `kubectl get namespace hangar` reports that the namespace is not found.

You can now read a plan, tell an edit from a replacement, freeze a reviewed plan and guard a resource. The plan was possible only because OpenTofu remembered which real objects it owns. The next step is to study that memory, what happens when the real objects change behind its back and how an existing resource becomes managed.

## Common pitfalls

> [!WARNING]
> - Do not skim a plan for the summary line only. `1 to change` can hide a `-/+` replacement. Search for `forces replacement`.
> - Do not apply an old plan file after the files changed. Create a new plan, or OpenTofu refuses the old one.
> - `prevent_destroy` is not a backup. It does not stop deletion through `kubectl` or through removing the block.
> - Do not run `tofu destroy` in a working directory whose state you do not recognise. It deletes everything that the state lists.
