output "frontend_id" {
  description = "ID of the frontend instance"
  value       = aws_instance.frontend[0].id
}