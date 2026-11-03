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
    mode  = "active"
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
