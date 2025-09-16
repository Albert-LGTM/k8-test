terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.30"
    }
  }
  required_version = ">= 1.5"
}

provider "digitalocean" {
  token = var.do_token
}

# Upload SSH key to DigitalOcean (if not already created)
#resource "digitalocean_ssh_key" "default" {
#  name       = var.ssh_key_id
#  public_key = var.ssh_pub_key
#}

# Create multiple Kubernetes clusters
resource "digitalocean_kubernetes_cluster" "clusters" {
  for_each = toset(var.cluster_names)

  name    = each.key
  region  = element(var.regions, index(var.cluster_names, each.key) % length(var.regions))
  version = "1.33.1-do.3"

  node_pool {
    name       = "${each.key}-pool"
    size       = var.node_size
    node_count = var.node_count
    auto_scale = false
  }
}

output "cluster_endpoints" {
  description = "Kubernetes API endpoints for all clusters"
  value = { for k, cluster in digitalocean_kubernetes_cluster.clusters : k => cluster.endpoint }
}
