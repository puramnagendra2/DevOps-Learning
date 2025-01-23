output "server_link" {
  value = "http://${aws_instance.webserver_instance.public_ip}"
}