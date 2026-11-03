# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Read the hand-made objects

Look at what exists, because the files must describe it:

```sh
kubectl -n hangar get configmap hangar-settings -o yaml
kubectl -n hangar get deployment beacon -o yaml
```

The ConfigMap holds `mode: manual`. The Deployment has five replicas, the selector `app: beacon`, the container `beacon` and a CPU and memory request. Create the working directory:

```sh
mkdir hangar-import
cd hangar-import
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

## Step 2: Write the import blocks and the resources

Save this as `main.tf`:

```hcl
import {
  to = kubernetes_namespace_v1.hangar
  id = "hangar"
}

import {
  to = kubernetes_config_map_v1.settings
  id = "hangar/hangar-settings"
}

import {
  to = kubernetes_deployment_v1.beacon
  id = "hangar/beacon"
}

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
    namespace = "hangar"
    labels = {
      "managed-by" = "opentofu"
    }
  }

  data = {
    mode  = "active"
    owner = "platform"
  }
}

resource "kubernetes_deployment_v1" "beacon" {
  metadata {
    name      = "beacon"
    namespace = "hangar"
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
              name = "hangar-settings"
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }
        }
      }
    }
  }
}
```

The ConfigMap and the Deployment use the plain namespace name here, because the namespace is imported and exists already.

## Step 3: Plan, read, apply

```sh
tofu init
tofu plan
```

The plan reports three resources to import. It also shows updates in place: the new labels, the new ConfigMap data, and the replica count from 5 to 2. Search it for `forces replacement`. The text must not appear. If it does, a field in your block differs from the real object in a way that cannot be edited, for example the selector. Fix the block and plan again. Then apply:

```sh
tofu apply
```

Check that the objects are the original ones. The identifiers must equal the ones that the lab recorded:

```sh
kubectl get namespace hangar -o jsonpath='{.metadata.uid}{"\n"}'
kubectl -n default get configmap seed-record -o jsonpath='{.data.namespace-uid}{"\n"}'
```

The two lines are equal. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01 --keep
```

## Step 4: Create drift, detect it and restore

Scale the Deployment by hand, then ask for a plan with the detailed exit code:

```sh
kubectl -n hangar scale deployment beacon --replicas=4
tofu plan -detailed-exitcode
echo $?
```

The plan shows `replicas` changing from 4 to 2, and the exit code is `2`. Restore the declared state:

```sh
tofu apply
tofu plan -detailed-exitcode
echo $?
```

The second plan exits with `0`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01
```

All four checks pass. If `beacon-reconciled` fails, wait until the extra pods are gone and submit again. Clean up with `astrona destroy ats-066-lab-020-02`.
