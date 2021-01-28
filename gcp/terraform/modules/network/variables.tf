variable "network_name" {
    type = string
    description = "VPC name for kube VPC"
}

variable "cluster_region" { 
    type = string
    description = "Compute region for the cluster"
    default = "us-west1"
}

variable "cluster_zone" { 
    type = string
    description = "Compute zone for the cluster"
    default = "us-west1-c"
}