resource "google_compute_network" "kube_network" {
  name = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kube_subnet" {
  name = "kube-subnet1"
  network = google_compute_network.kube_network.id
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.kube_network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]

  depends_on = [ google_compute_network.kube_network, google_compute_subnetwork.kube_subnet ]
}

resource "google_compute_firewall" "allow_external" {
  name    = "${var.network_name}-allow-external"
  network = google_compute_network.kube_network.name

  allow {
    protocol = "tcp"
    ports = [ "22", "6443" ]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [ "0.0.0.0/0" ]
  depends_on = [ google_compute_network.kube_network, google_compute_subnetwork.kube_subnet ]
}

resource "google_compute_address" "public_address" {
  name = "kube-external-ip"
  region = var.cluster_region
}
