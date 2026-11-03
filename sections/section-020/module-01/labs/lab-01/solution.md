# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Prepare the working directory

Create a directory and tell OpenTofu which kubeconfig to use. It is the file that `kubectl` uses:

```sh
mkdir hangar-tofu
cd hangar-tofu
export KUBE_CONFIG_PATH="$KUBECONFIG"
```

Save this as `versions.tf`:

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

## Step 2: Declare the three resources

Save this as `main.tf`:

```hcl
resource "kubernetes_namespace_v1" "hangar" {
  metadata {
    name = "hangar"
    labels = {
      "managed-by" = "opentofu"
    }
  }
}

resource "kubernetes_config_map_v1" "settings" {
  metadata {
    name      = "hangar-settings"
    namespace = kubernetes_namespace_v1.hangar.metadata[0].name
    labels = {
      "managed-by" = "opentofu"
    }
  }

  data = {
    mode  = "standby"
    owner = "platform"
  }
}

resource "kubernetes_deployment_v1" "beacon" {
  metadata {
    name      = "beacon"
    namespace = kubernetes_namespace_v1.hangar.metadata[0].name
    labels = {
      app          = "beacon"
      "managed-by" = "opentofu"
    }
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

## Step 3: Initialise, plan and apply

```sh
tofu init
tofu plan
tofu apply
```

The plan shows three resources to add. After you type `yes`, the provider creates the namespace first and then the ConfigMap and the Deployment, because they refer to the namespace. The apply waits until the Deployment has rolled out. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01 --keep
```

The checks `namespace-declared` and `beacon-deployment` pass. The check `settings-configmap` fails, because `mode` is still `standby`.

## Step 4: Change the setting through the file

Change `mode = "standby"` to `mode = "active"` in `main.tf`, and plan:

```sh
tofu plan
```

The plan shows one resource with a tilde, which is an update in place, and one changed line. No resource is replaced. Apply it:

```sh
tofu apply
```

## Step 5: Restart the pods

The pods started before the change, and a running container keeps the environment it started with. Check one pod and then restart the Deployment:

```sh
kubectl -n hangar exec deploy/beacon -- printenv mode
kubectl -n hangar rollout restart deployment/beacon
kubectl -n hangar rollout status deployment/beacon
kubectl -n hangar exec deploy/beacon -- printenv mode
```

The first command prints `standby` and the last one prints `active`. The restart changes the live Deployment, so the next `tofu plan` may report a difference in a field that the provider tracks, such as an annotation. That does not affect the grade. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01
```

All four checks pass. If `pods-read-active-mode` fails, wait until the old pods are gone and submit again. Clean up with `astrona destroy ats-066-lab-020-01`.
