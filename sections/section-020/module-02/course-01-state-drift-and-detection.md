---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# State, Drift And Detection

A configuration file says what you want. It does not say which real object belongs to each block. If OpenTofu had to guess, it could adopt the wrong object or create a duplicate. The state file solves this, and it is also the reason that infrastructure as code needs more care than a plain configuration file. This part looks inside the state, makes a change behind the tool's back and detects it.

## What the state holds

The state is a JSON document. For every managed resource it records the address (`kubernetes_namespace_v1.hangar`), the provider that manages it, the identity of the real object and the attribute values that the provider returned at the last refresh. The OpenTofu program writes the state after every successful apply, and the provider supplies the values.

The identity is what makes the link work. For a Kubernetes namespace the identity is the name, and for a namespaced object it is `namespace/name`. If you rename a resource block in a file without telling OpenTofu, the tool sees a missing address and a new address. It then plans to destroy the old object and create a new one. The files and the state must agree on the addresses.

The state can contain values that never appear in your files. A provider returns every attribute of an object, which can include generated passwords, tokens and connection strings. For that reason, treat the state as a secret. Do not publish it, and limit who can read it. OpenTofu also supports encrypting the state before it is written, which protects a state file that is stored in a shared place.

## Where the state lives

The default backend stores the state in a local file named `terraform.tfstate` in the working directory. That is enough for one person who learns the tool. It fails for a team, for two reasons. The file exists only on one machine, and two people can run an apply at the same moment. A remote backend stores the state in a shared service and, for many backends, takes a lock for the duration of a write. A lock makes the second apply wait or fail, so two applies never write the state together. If the state is lost, OpenTofu no longer knows what it owns. The real objects still exist, and a new apply tries to create them again and fails, or creates duplicates in systems that allow it.

Look at the state of a working directory that has applied the `hangar` files. If you start with an empty directory, first save the three files below and apply them. Save this as `versions.tf`:

<!-- astrona:playground:renew -->

```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {}
```

Save this as `hangar.tf`:

```hcl
resource "kubernetes_namespace_v1" "hangar" {
  metadata {
    name = "hangar"
  }
}

resource "kubernetes_deployment_v1" "beacon" {
  metadata {
    name      = "beacon"
    namespace = kubernetes_namespace_v1.hangar.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "beacon"
      }
    }

    template {
      metadata {
        labels = {
          app = "beacon"
        }
      }

      spec {
        container {
          name  = "beacon"
          image = "ghcr.io/stefanprodan/podinfo:6.15.0"

          port {
            container_port = 9898
          }
        }
      }
    }
  }
}
```

Set the kubeconfig, initialise and apply:

```sh
export KUBE_CONFIG_PATH="$KUBECONFIG"
tofu init
tofu apply
```

List what OpenTofu owns, and print the recorded values of one resource:

```sh
tofu state list
tofu state show kubernetes_deployment_v1.beacon
```

The list shows the two addresses. The `state show` command prints the attributes that were stored, including the replica count of `2`. Do not edit the state file with a text editor. Commands such as `tofu state rm` and `tofu state mv` exist for deliberate repairs, and they keep the file consistent.

## What drift is

Drift is a difference between the real object and what OpenTofu expects, caused by a change that did not go through OpenTofu. A person scaled a Deployment during an incident, a controller added a field, or a script edited a ConfigMap. The files and the state still say the old value. Create a drift now:

```sh
kubectl -n hangar scale deployment beacon --replicas=5
kubectl -n hangar get deployment beacon
```

The Deployment reports five replicas. The files say two, and the state also says two, because OpenTofu has not looked yet. Nothing in the cluster tells OpenTofu about the change. The tool finds out only when you run a command that refreshes.

## Detecting drift without changing anything

`tofu plan` refreshes first. The provider reads the Deployment, sees five replicas and the plan shows an update in place that sets `replicas` from `5` to `2`. The plan compares the real object with the files, so it proposes to undo the manual change. Run it and read the line for `replicas`:

```sh
tofu plan
```

Sometimes you want to see the drift and not the fix. The refresh-only mode builds a plan that updates the state to match the real objects and proposes no change to the objects:

```sh
tofu plan -refresh-only
```

It reports that the Deployment changed outside OpenTofu and shows the old and new value. Applying a refresh-only plan with `tofu apply -refresh-only` writes the five replicas into the state and leaves the cluster alone. After that, the state says five and the files say two, so a normal plan still proposes the change to two. Accepting drift into the state is not the same as accepting it into the files. If five replicas is the right number, edit the file to say five.

A pipeline needs the result as a code and not as text. The flag `-detailed-exitcode` changes the exit codes of `tofu plan`: 0 means no changes, 1 means an error and 2 means a non-empty plan. A scheduled job that runs `tofu plan -detailed-exitcode` and alerts on exit code 2 detects drift without a person reading the output. Check the exit code in the shell:

```sh
tofu plan -detailed-exitcode
echo $?
```

The command prints `2` while the Deployment has five replicas. Restore the declared state with an apply, and run the plan again to see exit code 0:

```sh
tofu apply
tofu plan -detailed-exitcode
echo $?
```

You now know how OpenTofu remembers objects, why the memory is sensitive and how a plan exposes a change made elsewhere. What you cannot yet do is bring an object into this memory that already existed before the files did. The next part does that and then asks how much of this workflow is GitOps.

## Common pitfalls

> [!WARNING]
> - A drift report is a symptom. Decide which side is right before you apply: the files, or the manual change.
> - `tofu apply -refresh-only` changes the state and not the cluster. It does not accept the change into the files.
> - Do not rename a resource block without a `moved` block or `tofu state mv`. OpenTofu plans to destroy and create the object.
> - A local state file on one laptop is a single point of failure. Losing it leaves real objects that no file claims.
