output "frontend_id" {
  description = "ID of the frontend instance"
  value       = aws_instance.frontend[0].id
}

output "backend_auth_id" {
  description = "ID of the backend auth module instance"
  value       = aws_instance.backend[0].id
}

output "ai_id" {
  description = "ID of the ai instance"
  value       = aws_instance.ai[0].id
}