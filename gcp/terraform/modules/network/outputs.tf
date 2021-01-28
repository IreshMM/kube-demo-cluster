output "kube_subnet" {
    value = google_compute_subnetwork.kube_subnet
    description = "Kube subnetwork information"
}