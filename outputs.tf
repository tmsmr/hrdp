output "ssh_conn" {
  value = {
    ipv4_address = hcloud_server.hrdp_node.ipv4_address
    known_hosts  = "session/known_hosts"
    id_ecdsa     = "session/id_ecdsa"
    user_name    = "hrdp"
  }
}

output "xrdp_pass" {
  value = random_string.user_pass.result
}

output "xrdp_cert_sha1" {
  value = data.local_file.xrdp_sha1_fp.content
}
