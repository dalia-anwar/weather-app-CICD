output "vpc_id" {
    value = aws_vpc.vpc.id
}

# all public subnets ID
output "public_subnet1_id" {
    value = aws_subnet.public_subnet_1.id
}
output "public_subnet2_id" {
    value = aws_subnet.public_subnet_2.id
}
# # all private subnets ID
# output "private_subnets_id" {
#     value = aws_subnet.private_subnets[*].id
# }
