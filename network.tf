resource "yandex_vpc_network" "develop" {
  name = "my-net"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "my-net-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.1.0/24"]
  route_table_id = yandex_vpc_route_table.route.id
}

resource "yandex_vpc_subnet" "subnet_d" {
  name           = "my-net-ru-central1-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.route.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "my-net-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route" {
  name       = "my-net-route-table"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name       = "my-net-bastion-sec-gr"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "SSH input rule"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Permit any traffic from output"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "my-net-lan-sec-gr"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Permit connections from my VMs to my VMs on the same network"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    description    = "Permit any traffic from output"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "my-net-web-sec-gr"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow input HTTPS traffic"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow input HTTP traffic"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}