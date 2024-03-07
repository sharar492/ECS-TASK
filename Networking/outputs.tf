output "public_subnets" {
  value = [aws_subnet.subnet-1.id]
}

output "private_subnets" {
  value = [aws_subnet.subnet-2.id]
}

output "security_group_id" {
  value = aws_security_group.sg1.id
}
