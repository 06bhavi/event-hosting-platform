output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "nagios_public_ip" {
  description = "Public IP of the Nagios server"
  value       = aws_instance.nagios.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "nagios_url" {
  value = "http://${aws_instance.nagios.public_ip}/nagios"
}
