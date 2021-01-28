module "kube_network" {
  source = "./modules/network"
  network_name = "kubernetes-the-hard-way"
}

module "kube_compute" {
    source = "./modules/compute"
    kube_subnet = module.kube_network.kube_subnet
}