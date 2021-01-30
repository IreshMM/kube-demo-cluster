resource "google_compute_network" "kube_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kube_subnet" {
  name          = "kube-subnet1"
  network       = google_compute_network.kube_network.id
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.kube_network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]

  depends_on = [google_compute_network.kube_network, google_compute_subnetwork.kube_subnet]
}

resource "google_compute_firewall" "allow_external" {
  name    = "${var.network_name}-allow-external"
  network = google_compute_network.kube_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  depends_on    = [google_compute_network.kube_network, google_compute_subnetwork.kube_subnet]
}

resource "google_compute_address" "public_address" {
  name   = "kube-external-ip"
  region = var.cluster_region
}

resource "google_compute_http_health_check" "http_health_check" {
  name = "http-health-check"
  description  = "Kubernetes Health Check"
  host         = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.network_name}-allow-health-check"
  network = google_compute_network.kube_network.name

  allow {
    protocol = "tcp"
  }
  source_ranges = ["209.85.152.0/22" ,"209.85.204.0/22", "35.191.0.0/16"]

  depends_on = [google_compute_network.kube_network, google_compute_subnetwork.kube_subnet]
}

resource "google_compute_target_pool" "kubernetes_target_pool" {
  name = "kubernetes-target-pool"
  health_checks = [ google_compute_http_health_check.http_health_check.name ]

  instances = formatlist("${var.cluster_zone}/controller-%s", range(3))
}

resource "google_compute_forwarding_rule" "kubernetes_forwarding_rule" {
  name = "kubernetes-forwarding-rule"
  ip_address = google_compute_address.public_address.address
  port_range = "6443"
  region = var.cluster_region
  target = google_compute_target_pool.kubernetes_target_pool.id
}