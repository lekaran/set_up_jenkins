output "jenkins_pub_ip" {
  value = aws_eip.jenkins_public_ip.public_ip
}

output "jenkins_pub_dns" {
  value = aws_eip.jenkins_public_ip.public_dns
}