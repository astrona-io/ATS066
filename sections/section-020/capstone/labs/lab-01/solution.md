# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Set up the directory

```sh
kubectl -n depot get configmap depot-settings -o jsonpath='{.data}{"\n"}'
mkdir depot-tofu
cd depot-tofu
export KUBE_CONFIG_PATH="$KUBECONFIG"
```

The ConfigMap holds `tier` with the value `bronze`. Save this as `versions.tf`:

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

## Step 2: Import and declare

Save this as `main.tf`:

```hcl
import {
  to = kubernetes_namespace_v1.depot
  id = "depot"
}

import {
  to = kubernetes_config_map_v1.settings
  id = "depot/depot-settings"
}

resource "kubernetes_namespace_v1" "depot" {
  metadata {
    name = "depot"
    labels = {
      "managed-by" = "opentofu"
    }
  }
}

resource "kubernetes_config_map_v1" "settings" {
  metadata {
    name      = "depot-settings"
    namespace = kubernetes_namespace_v1.depot.metadata[0].name
    labels = {
      "managed-by" = "opentofu"
    }
  }

  data = {
    tier = "gold"
  }
}

resource "kubernetes_resource_quota_v1" "quota" {
  metadata {
    name      = "depot-quota"
    namespace = kubernetes_namespace_v1.depot.metadata[0].name
    labels = {
      "managed-by" = "opentofu"
    }
  }

  spec {
    hard = {
      pods = "10"
    }
  }
}

resource "kubernetes_deployment_v1" "relay" {
  metadata {
    name      = "relay"
    namespace = kubernetes_namespace_v1.depot.metadata[0].name
    labels = {
      app          = "relay"
      "managed-by" = "opentofu"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "relay"
      }
    }

    template {
      metadata {
        labels = {
          app = "relay"
        }
      }

      spec {
        container {
          name  = "relay"
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

  depends_on = [kubernetes_resource_quota_v1.quota]
}

resource "kubernetes_service_v1" "relay" {
  metadata {
    name      = "relay"
    namespace = kubernetes_namespace_v1.depot.metadata[0].name
    labels = {
      "managed-by" = "opentofu"
    }
  }

  spec {
    selector = {
      app = "relay"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 9898
    }
  }
}
```

The Deployment depends on the quota on purpose. A quota that exists before the pods makes the quota count the pods from the first one.

## Step 3: Plan and apply

```sh
tofu init
tofu plan
```

The plan reports two resources to import, an update in place for the labels and the `tier` value, and three resources to add. Check that `forces replacement` does not appear. Apply:

```sh
tofu apply
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01 --keep
```

The checks for the imported objects, the tier, the quota and the Service pass.

## Step 4: Drift

```sh
kubectl -n depot scale deployment relay --replicas=3
tofu plan -detailed-exitcode
echo $?
tofu apply
```

The plan shows the replica count going from 3 to 2 and exits with `2`. The apply restores two replicas. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01
```

All checks pass. If `relay-deployment` fails, wait until the third pod is gone and submit again. Clean up with `astrona destroy ats-066-capstone-020`.
