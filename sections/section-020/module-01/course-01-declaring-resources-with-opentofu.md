---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Declaring Resources With OpenTofu

A team that creates infrastructure by hand with commands and web consoles has no record of what exists or why. Another person cannot review the change before it happens, and nobody can repeat it exactly. Infrastructure as code (IaC) solves this by writing the desired resources in text files, which a version control system can store and review. This part writes the first files, runs OpenTofu and shows which component does each step.

## What a declaration is

A declaration states what should exist and leaves out the steps to create it. The text "a namespace named `hangar` with the label `managed-by` set to `opentofu`" is a declaration. The `kubectl create namespace` command is an instruction: it runs once and leaves no file behind. OpenTofu reads declarations, asks the target API what exists, and works out the steps itself.

OpenTofu does not know any API by itself. A provider is a plugin that OpenTofu downloads and starts, and it translates a resource block into calls to one API. For Kubernetes the provider is `hashicorp/kubernetes`. When you run `tofu apply`, the OpenTofu program decides what must change, and the provider sends the HTTP requests to the Kubernetes API server. The API server then stores the object, exactly as it does for `kubectl`.

## Infrastructure and application configuration

Both kinds of files describe desired state, so people mix them up. Infrastructure declarations describe the things an application runs on or inside: namespaces, quotas, networks, databases, identities. Application configuration describes how one application behaves: a message, a feature setting, a connection string. The boundary matters because the owner and the change rate differ. A platform team may change a namespace quota once a month, and an application team may change a setting every day. In this module OpenTofu declares the namespace and the Deployment, and the ConfigMap shows the point where the two meet.

## The first files

Create an empty working directory on your machine, for example `hangar-tofu`, and change into it. OpenTofu reads every file that ends in `.tf` in that directory. Tell the shell which kubeconfig to use, because OpenTofu does not read `kubectl` settings by itself:

<!-- astrona:playground:renew -->

```sh
export KUBE_CONFIG_PATH="$KUBECONFIG"
mkdir hangar-tofu
cd hangar-tofu
```

If `KUBECONFIG` is empty on your machine, set `KUBE_CONFIG_PATH` to the path of the kubeconfig file that `kubectl` uses. Save this as `versions.tf`:

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

The `required_providers` block says which provider to download and which versions are acceptable. The constraint `~> 2.35` allows 2.35 and any later 2.x release, and blocks a new major version that could change behavior. The empty `provider` block means that the provider takes its connection settings from the environment, here from `KUBE_CONFIG_PATH`.

Now save the first resource as `namespace.tf`:

```hcl
resource "kubernetes_namespace_v1" "hangar" {
  metadata {
    name = "hangar"
    labels = {
      "managed-by" = "opentofu"
    }
  }
}
```

A resource block has a type (`kubernetes_namespace_v1`), a local name (`hangar`) and a body. The two words together, `kubernetes_namespace_v1.hangar`, are the address of the resource. OpenTofu uses the address to find this resource in its state and in plans.

## Initialise, plan, apply

Download the provider with the first command. It creates a `.terraform` directory with the plugin and a `.terraform.lock.hcl` file that records the exact provider version and its checksums:

```sh
tofu init
```

Then ask for a plan. This command reads the cluster and your files and changes nothing:

```sh
tofu plan
```

The plan lists one resource with a plus sign, which means create, and ends with a summary line of the form `Plan: 1 to add, 0 to change, 0 to destroy.` Nothing exists in the cluster yet, so OpenTofu has nothing to compare against. Apply it:

```sh
tofu apply
```

OpenTofu shows the plan again and asks you to type `yes`. After you confirm, the provider creates the namespace and OpenTofu writes a file named `terraform.tfstate` in the working directory. Check the result with the normal client, which proves that the object is an ordinary Kubernetes object:

```sh
kubectl get namespace hangar --show-labels
```

## Adding a ConfigMap and a Deployment

The namespace is empty, so add the objects that live inside it. A resource can refer to another resource, and the reference tells OpenTofu the order. Save this as `workload.tf`:

```hcl
resource "kubernetes_config_map_v1" "settings" {
  metadata {
    name      = "hangar-settings"
    namespace = kubernetes_namespace_v1.hangar.metadata[0].name
  }

  data = {
    mode = "standby"
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

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.settings.metadata[0].name
            }
          }
        }
      }
    }
  }
}
```

The reference `kubernetes_namespace_v1.hangar.metadata[0].name` is read as "the name attribute of the first metadata block of that resource". It does two jobs. It supplies the value, and it tells OpenTofu that the namespace must exist before the ConfigMap. OpenTofu builds a graph of these dependencies and creates independent resources in parallel. The Deployment refers to the ConfigMap, so OpenTofu creates the ConfigMap first.

Plan and apply again, then look at what exists:

```sh
tofu plan
tofu apply
kubectl -n hangar get configmap,deployment
```

This plan shows two resources to add, and the namespace is not in the list. OpenTofu found the namespace in its state, compared it with the cluster and saw no difference. The Deployment resource waits until the rollout is ready before the apply finishes, because the provider option `wait_for_rollout` is true by default.

## What changes when you edit a file

Open `workload.tf` and change `mode = "standby"` to `mode = "active"`. Run `tofu plan`. The plan marks the ConfigMap with a tilde, which means update in place, and shows the one line that changes. The namespace and the Deployment are not touched. A ConfigMap value can be edited in the API, so OpenTofu edits it and does not delete anything. Apply the change and read the value back:

```sh
tofu apply
kubectl -n hangar get configmap hangar-settings -o jsonpath='{.data.mode}{"\n"}'
```

The Deployment still runs the old value in its environment, because a running container never sees a changed environment variable. That is a fact about Kubernetes and not about OpenTofu: the tool changed the object correctly, and the application needs a new pod to read it.

You have now seen the full loop for a declaration: write, initialise once, plan, apply, verify with the normal client. You still do not know how OpenTofu decides between an in-place update and a destroy-and-create, and you have not seen the file that remembers what it owns. The next part reads plans in detail.

## Common pitfalls

> [!WARNING]
> - Do not run `tofu` without setting `KUBE_CONFIG_PATH`: the plan fails because the provider has no cluster to talk to, or it uses a different cluster than `kubectl`.
> - Do not commit `terraform.tfstate` or the `.terraform` directory to a public repository. The state can hold values that you did not write in the files.
> - Do not mix hand-made `kubectl` changes with resources that OpenTofu manages. The next plan shows the difference, and the apply can undo your change.
> - A passing `tofu apply` shows that the API accepted the objects. It does not show that the application inside them works.
