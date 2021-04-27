
### Cloud provider conf
variable az { default = "FR_Roubaix" }
variable volumetype { default = "HDD SATA" }
## Cloud from terraform/clouds.yaml
variable oscloud { default = "openstack" }

### SSH configuration
variable ssh_priv_file { default = "~/.ssh/id_rsa" }
variable ssh_pub_file { default = "~/.ssh/id_rsa.pub" }

### OpenStack-Ansible
variable osa_repo { default = "https://github.com/openstack/openstack-ansible" }
variable osa_version { default = "stable/victoria" }
