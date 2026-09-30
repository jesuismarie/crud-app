locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    var.common_tags,
    var.tags
  )

  public_count  = length(var.public_subnet_cidrs)
  private_count = length(var.private_subnet_cidrs)
  az_count      = length(var.azs)

  nat_count        = var.single_nat_gateway ? 1 : local.private_count
  private_rt_count = var.single_nat_gateway ? 1 : local.private_count
}

resource "terraform_data" "validation" {
  lifecycle {
    precondition {
      condition     = local.public_count == local.az_count
      error_message = "public_subnet_cidrs count (${local.public_count}) must equal azs count (${local.az_count})."
    }

    precondition {
      condition     = local.private_count == local.az_count
      error_message = "private_subnet_cidrs count (${local.private_count}) must equal azs count (${local.az_count})."
    }

    precondition {
      condition     = local.public_count == local.private_count
      error_message = "public_subnet_cidrs and private_subnet_cidrs must have the same length."
    }
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })

  depends_on = [terraform_data.validation]
}

# Public Subnet
resource "aws_subnet" "public" {
  count = local.public_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, var.public_subnet_tags, {
    Name = "${local.name_prefix}-public-${var.azs[count.index]}",
  })
}

# Private Subnet
resource "aws_subnet" "private" {
  count = local.private_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(local.common_tags, var.private_subnet_tags, {
    Name = "${local.name_prefix}-private-${var.azs[count.index]}",
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateways
resource "aws_nat_gateway" "ngw" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  count = local.private_rt_count

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_nat" {
  count = local.nat_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route_table_association" "private" {
  count = local.private_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = local.private_rt_count == 1 ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}
