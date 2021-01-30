terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.54.0"
    }
  }
}

provider "google" {
    project = "kube-demo1-303310"
    region = "us-west1"
    zone = "us-west1-c"
}