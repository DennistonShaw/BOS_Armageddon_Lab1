# Required: Read the São Paulo TGW ID from its remote state
# Adjust backend config (bucket/key/region/etc.) to match your São Paulo setup
data "terraform_remote_state" "saopaulo" {
   backend = "s3"  # or "remote" for Terraform Cloud, etc.

  config = {
    bucket = "your-terraform-state-bucket-name"
    key    = "path/to/saopaulo/terraform.tfstate"  # e.g. "env:/saopaulo/terraform.tfstate"
    region = "sa-east-1"
    # dynamodb_table = "terraform-locks"   # if using
    # profile        = "your-profile"      # if needed
  }
}

# Explanation: Shinjuku Station is the hub—Tokyo is the data authority.
resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
  description = "shinjuku-tgw01 (Tokyo hub)"
  tags = { Name = "shinjuku-tgw01" }
}

# Explanation: Shinjuku connects to the Tokyo VPC—this is the gate to the medical records vault.
resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
  vpc_id             = aws_vpc.edo_vpc01.id
  subnet_ids         = aws_subnet.edo_private_subnets[*].id
  tags = { Name = "shinjuku-attach-tokyo-vpc01" }
}

# Explanation: Shinjuku opens a corridor request to Liberdade—compute may travel, data may not.
resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade_peer01" {
  transit_gateway_id      = aws_ec2_transit_gateway.shinjuku_tgw01.id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = data.terraform_remote_state.saopaulo.outputs.liberdade_tgw_id

  tags = {
    Name              = "shinjuku-to-liberdade-peer01"
    "peering:from"    = "tokyo"
    "peering:to"      = "saopaulo"
    "peering:purpose" = "compute-access-only"
  }
}

# Output for reference (optional)
output "shinjuku_tgw_id" {
  value       = aws_ec2_transit_gateway.shinjuku_tgw01.id
  description = "Tokyo Transit Gateway ID"
}