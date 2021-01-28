resource "google_compute_instance" "control_plane" {
  name  = "controller-${count.index}"
  count = 3
  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  can_ip_forward = true
  machine_type   = "e2-standard-2"

  network_interface {
    subnetwork = var.kube_subnet.name
    network_ip = cidrhost(var.kube_subnet.ip_cidr_range, 10 + count.index)
    access_config {}
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    "ssh-keys" = "iresh:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["kubernetes-the-hard-way", "controller"]
}

resource "google_compute_instance" "workers" {
  name  = "worker-${count.index}"
  count = 1
  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  can_ip_forward = true
  machine_type   = "e2-standard-2"

  network_interface {
    subnetwork = var.kube_subnet.name
    network_ip = cidrhost(var.kube_subnet.ip_cidr_range, 20 + count.index)
    access_config {}
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    "ssh-keys" = "iresh:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["kubernetes-the-hard-way", "worker"]
}

data "google_client_openid_userinfo" "me" {}
data "google_project" "project" {}

resource "google_os_login_ssh_public_key" "ssh_key" {
  user    = data.google_client_openid_userinfo.me.email
  key     = file("~/.ssh/id_rsa.pub")
  project = data.google_project.project.project_id
}
