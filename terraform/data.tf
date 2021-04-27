
data "openstack_networking_router_v2" "private_router" {
  name = "private_router"
}

data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 20.04 LTS - Focal"
  most_recent = true
}

data "openstack_compute_flavor_v2" "controller_flavor" {
  ram   = 65536
}

data "openstack_compute_flavor_v2" "compute_flavor" {
  ram   = 12288
  vcpus = 12
}

data "openstack_compute_flavor_v2" "deployer_flavor" {
  ram   = 12288
  vcpus = 8
}
