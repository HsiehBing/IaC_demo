
############################################
# Associate route table
############################################

resource "aws_route_table_association" "public_associate" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.route_public.id
}
