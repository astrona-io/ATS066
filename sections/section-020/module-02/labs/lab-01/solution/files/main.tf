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
