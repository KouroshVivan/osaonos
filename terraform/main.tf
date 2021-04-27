resource "openstack_compute_keypair_v2" "my-keypair" {
  name       = "my-keypair"
  public_key = file(var.ssh_pub_file)
}


resource "openstack_blockstorage_volume_v3" "cindervol" {
  name = "cindervol"
  volume_type = var.volumetype
  availability_zone = var.az
  size = 100
}

resource "openstack_compute_instance_v2" "deployer1" {
  name              = "deployer1"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.deployer_flavor.id
  key_pair          = openstack_compute_keypair_v2.my-keypair.id
  availability_zone = var.az
  user_data         = templatefile("templates/user-data-deployer.tmpl",
  {
    ssh_private_key = indent(6,file(var.ssh_priv_file)),
    ssh_public_key = indent(6,file(var.ssh_pub_file)),
    branch = var.osa_version
    repo = var.osa_repo
  }
  )
  network {
    port = openstack_networking_port_v2.deployer1_pro_port.id
  }
  network {
    port = openstack_networking_port_v2.deployer1_api_port.id
  }
}

resource "openstack_compute_instance_v2" "controller1" {
  name            = "controller1"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.controller_flavor.id
  key_pair        = openstack_compute_keypair_v2.my-keypair.id
  availability_zone = var.az
  user_data         = templatefile("templates/user-data-target.tmpl",
  {
    ssh_private_key = indent(6,file(var.ssh_priv_file)),
    ssh_public_key = indent(6,file(var.ssh_pub_file))
  }
  )
  network {
    port = openstack_networking_port_v2.controller1_pro_port.id
  }
  network {
    port = openstack_networking_port_v2.controller1_api_port.id
  }
  network {
    port = openstack_networking_port_v2.controller1_sto_port.id
  }
  network {
    port = openstack_networking_port_v2.controller1_vxlan_port.id
  }
}

resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = openstack_compute_instance_v2.controller1.id
  volume_id   = openstack_blockstorage_volume_v3.cindervol.id
}

resource "openstack_compute_instance_v2" "compute1" {
  name            = "compute1"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.compute_flavor.id
  key_pair        = openstack_compute_keypair_v2.my-keypair.id
  availability_zone = var.az
  user_data         = templatefile("templates/user-data-target.tmpl",
  {
    ssh_private_key = indent(6,file(var.ssh_priv_file)),
    ssh_public_key = indent(6,file(var.ssh_pub_file))
  }
  )
  network {
    port = openstack_networking_port_v2.compute1_pro_port.id
  }
  network {
    port = openstack_networking_port_v2.compute1_api_port.id
  }
  network {
    port = openstack_networking_port_v2.compute1_sto_port.id
  }
  network {
    port = openstack_networking_port_v2.compute1_vxlan_port.id
  }
}

resource "openstack_compute_instance_v2" "compute2" {
  name            = "compute2"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.compute_flavor.id
  key_pair        = openstack_compute_keypair_v2.my-keypair.id
  availability_zone = var.az
  user_data         = templatefile("templates/user-data-target.tmpl",
  {
    ssh_private_key = indent(6,file(var.ssh_priv_file)),
    ssh_public_key = indent(6,file(var.ssh_pub_file))
  }
  )
  network {
    port = openstack_networking_port_v2.compute2_pro_port.id
  }
  network {
    port = openstack_networking_port_v2.compute2_api_port.id
  }
  network {
    port = openstack_networking_port_v2.compute2_sto_port.id
  }
  network {
    port = openstack_networking_port_v2.compute2_vxlan_port.id
  }
}

### NETWORKS

resource "openstack_networking_network_v2" "pro_network" {
  name           = "pro_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "api_network" {
  name           = "api_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "sto_network" {
  name           = "sto_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "vxlan_network" {
  name           = "vxlan_network"
  admin_state_up = "true"
}

### SUBNET NETWORKS

resource "openstack_networking_subnet_v2" "pro_subnet" {
  name       = "pro_subnet"
  network_id = openstack_networking_network_v2.pro_network.id
  cidr       = "192.168.4.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "api_subnet" {
  name       = "api_subnet"
  network_id = openstack_networking_network_v2.api_network.id
  cidr       = "192.168.1.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "sto_subnet" {
  name       = "sto_subnet"
  network_id = openstack_networking_network_v2.sto_network.id
  cidr       = "192.168.2.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "vxlan_subnet" {
  name       = "vxlan_subnet"
  network_id = openstack_networking_network_v2.vxlan_network.id
  cidr       = "192.168.3.0/24"
  ip_version = 4
}

## PORT NETWORK
#PRO (PROVIDER)
resource "openstack_networking_port_v2" "deployer1_pro_port" {
  name           = "deployer1_pro_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.pro_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.pro_subnet.id
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.pro_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "controller1_pro_port" {
  name           = "controller1_pro_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.pro_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.pro_subnet.id
    ip_address = "192.168.4.5"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.pro_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute1_pro_port" {
  name           = "compute1_pro_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.pro_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.pro_subnet.id
    ip_address = "192.168.4.6"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.pro_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute2_pro_port" {
  name           = "compute2_pro_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.pro_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.pro_subnet.id
    ip_address = "192.168.4.7"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.pro_secgroup.id,
  ]
}
#API
resource "openstack_networking_port_v2" "deployer1_api_port" {
  name           = "deployer1_api_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.api_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.api_subnet.id
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.api_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "controller1_api_port" {
  name           = "controller1_api_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.api_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.api_subnet.id
    ip_address = "192.168.1.4"
  }
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.api_subnet.id
    ip_address = "192.168.1.5"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.api_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute1_api_port" {
  name           = "compute1_api_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.api_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.api_subnet.id
    ip_address = "192.168.1.6"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.api_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute2_api_port" {
  name           = "compute2_api_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.api_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.api_subnet.id
    ip_address = "192.168.1.7"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.api_secgroup.id,
  ]
}
#STO (STORAGE)
resource "openstack_networking_port_v2" "controller1_sto_port" {
  name           = "controller1_sto_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.sto_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.sto_subnet.id
    ip_address = "192.168.2.5"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.sto_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute1_sto_port" {
  name           = "compute1_sto_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.sto_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.sto_subnet.id
    ip_address = "192.168.2.6"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.sto_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute2_sto_port" {
  name           = "compute2_sto_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.sto_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.sto_subnet.id
    ip_address = "192.168.2.7"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.sto_secgroup.id,
  ]
}
#VXLAN
resource "openstack_networking_port_v2" "controller1_vxlan_port" {
  name           = "controller1_vxlan_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.vxlan_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.vxlan_subnet.id
    ip_address = "192.168.3.5"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.vxlan_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute1_vxlan_port" {
  name           = "compute1_vxlan_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.vxlan_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.vxlan_subnet.id
    ip_address = "192.168.3.6"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.vxlan_secgroup.id,
  ]
}
resource "openstack_networking_port_v2" "compute2_vxlan_port" {
  name           = "compute2_vxlan_port"
  admin_state_up = "true"

  network_id = openstack_networking_network_v2.vxlan_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.vxlan_subnet.id
    ip_address = "192.168.3.7"
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.vxlan_secgroup.id,
  ]
}
### NETWORK SECURITY GROUP
resource "openstack_networking_secgroup_v2" "pro_secgroup" {
  name        = "pro_secgroup"
}
resource "openstack_networking_secgroup_v2" "api_secgroup" {
  name        = "api_secgroup"
}
resource "openstack_networking_secgroup_v2" "sto_secgroup" {
  name        = "sto_secgroup"
}
resource "openstack_networking_secgroup_v2" "vxlan_secgroup" {
  name        = "vxlan_secgroup"
}

resource "openstack_networking_secgroup_rule_v2" "pro_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.pro_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "pro_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.pro_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "pro_rule_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.pro_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "api_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.api_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "sto_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sto_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "vxlan_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.vxlan_secgroup.id
}

### FIP
resource "openstack_networking_floatingip_v2" "controller1_fip" {
  pool = "FELCLOUD_Internet"
}

resource "openstack_networking_floatingip_associate_v2" "controller1_fip" {
  floating_ip = openstack_networking_floatingip_v2.controller1_fip.address
  port_id = openstack_networking_port_v2.controller1_pro_port.id
}
resource "openstack_networking_floatingip_v2" "deployer1_fip" {
  pool = "FELCLOUD_Internet"
}

resource "openstack_networking_floatingip_associate_v2" "deployer1_fip" {
  floating_ip = openstack_networking_floatingip_v2.deployer1_fip.address
  port_id = openstack_networking_port_v2.deployer1_pro_port.id
}
resource "openstack_networking_floatingip_v2" "compute1_fip" {
  pool = "FELCLOUD_Internet"
}

resource "openstack_networking_floatingip_associate_v2" "compute1_fip" {
  floating_ip = openstack_networking_floatingip_v2.compute1_fip.address
  port_id = openstack_networking_port_v2.compute1_pro_port.id
}
resource "openstack_networking_floatingip_v2" "compute2_fip" {
  pool = "FELCLOUD_Internet"
}

resource "openstack_networking_floatingip_associate_v2" "compute2_fip" {
  floating_ip = openstack_networking_floatingip_v2.compute2_fip.address
  port_id = openstack_networking_port_v2.compute2_pro_port.id
}

### ROUTER
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = data.openstack_networking_router_v2.private_router.id
  subnet_id = openstack_networking_subnet_v2.pro_subnet.id
}

### OUTPUT
output "deployer1" {
  value = openstack_networking_floatingip_v2.deployer1_fip.address
}
output "controller1" {
  value = openstack_networking_floatingip_v2.controller1_fip.address
}
output "compute1" {
  value = openstack_networking_floatingip_v2.compute1_fip.address
}
output "compute2" {
  value = openstack_networking_floatingip_v2.compute2_fip.address
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("templates/inventory.tmpl",
 {
    deployer1_ip = openstack_networking_floatingip_v2.deployer1_fip.address,
    controller1_ip = openstack_networking_floatingip_v2.controller1_fip.address,
    compute1_ip = openstack_networking_floatingip_v2.compute1_fip.address,
    compute2_ip = openstack_networking_floatingip_v2.compute2_fip.address
 }
 )
 filename = "../hosts/all"
}
