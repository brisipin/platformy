terraform {
  required_providers {
    spot = {
      source = "rackerlabs/spot"
    }
  }
}

resource "spot_cloudspace" "tee_bot" {
  name   = var.cloudspace_name
  region = var.region

  # CNI: keep default calico unless you know you need something else.
  # cni = "calico"
}

resource "spot_spotnodepool" "core" {
  cloudspace_name = spot_cloudspace.tee_bot.name
  name            = "core-spot"

  server_class = var.core_server_class
  bid_price    = var.core_bid_price

  desired_nodes = var.core_desired_nodes

  labels = {
    "capacity-type" = "spot"
    "pool"          = "core"
    "workload-tier" = "baseline"
  }
}

resource "spot_spotnodepool" "workers_spot" {
  cloudspace_name = spot_cloudspace.tee_bot.name
  name            = "workers-spot"

  server_class = var.workers_server_class
  bid_price    = var.workers_bid_price

  desired_nodes = var.workers_desired_nodes

  labels = {
    "capacity-type" = "spot"
    "pool"          = "workers"
    "workload-tier" = "burst"
  }
}

data "spot_kubeconfig" "tee_bot" {
  cloudspace_name = spot_cloudspace.tee_bot.name
}
