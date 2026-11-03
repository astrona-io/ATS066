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
