
resource "aws_vpc" "sandboxvpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name: "sandbox-vpc"
  }
}

resource "aws_vpc" "othersandbox" {
  cidr_block = "11.1.0.0/16"
  tags = {
    Name: "othersandbox-vpc"
  }
}

data "aws_region" "current" {}

resource "aws_vpc_ipam" "test" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "test" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.test.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "test" {
  ipam_pool_id = aws_vpc_ipam_pool.test.id
  cidr         = "172.2.0.0/16"
}

resource "aws_vpc" "sandbox_3" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.test.id
  ipv4_netmask_length = 28
  depends_on = [
    aws_vpc_ipam_pool_cidr.test
  ]
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.sandboxvpc.id
  tags = {
    Name = "sandbox-gw1"
  }
}

resource "aws_vpc_peering_connection" "sandbox" {
  peer_vpc_id = aws_vpc.sandboxvpc.id
  vpc_id = aws_vpc.othersandbox.id
}

resource "aws_vpc_peering_connection_accepter" "othersandbox" {
  vpc_peering_connection_id = aws_vpc_peering_connection.sandbox.id
  auto_accept = true
}

resource "aws_route_table" "sandboxtest" {
  vpc_id = aws_vpc.sandboxvpc.id

  tags = {
    Name = "sandbox-rt"
  }
}

resource "aws_route" "extroute" {
  route_table_id = aws_route_table.sandboxtest.id
  destination_cidr_block = aws_vpc.othersandbox.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.sandbox.id
}