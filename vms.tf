data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }

  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id, yandex_vpc_security_group.LAN.id]
  }
}

resource "yandex_compute_instance" "web-a" {
  name        = "web-a"
  hostname    = "web-a"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }

  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id, yandex_vpc_security_group.LAN.id]
  }
}

resource "yandex_compute_instance" "web-d" {
  name        = "web-d"
  hostname    = "web-d"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }

  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_d.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id, yandex_vpc_security_group.LAN.id]
  }
}

resource "yandex_compute_instance" "bd" {
  name        = "bd"
  hostname    = "bd"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }

  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_d.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id, yandex_vpc_security_group.LAN.id]
  }
}

resource "local_file" "inventory" {
  content  = <<-XYZ
  [database]
  ${yandex_compute_instance.bd.network_interface.0.ip_address}

  [bastion]
  ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

  [webservers]
  ${yandex_compute_instance.web-a.network_interface.0.ip_address}
  ${yandex_compute_instance.web-d.network_interface.0.ip_address}

  [internal:children]
  webservers
  database

  [internal:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

  XYZ
  filename = "./hosts.ini"
}