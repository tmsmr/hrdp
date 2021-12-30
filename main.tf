resource "random_string" "session_id" {
  length  = 16
  special = false
}

resource "random_string" "user_pass" {
  length  = 16
  special = false
}

resource "hcloud_server" "hrdp_node" {
  name         = "hrdp-${random_string.session_id.result}"
  image        = var.image
  server_type  = var.type
  datacenter   = var.datacenter
  ssh_keys     = [hcloud_ssh_key.client_pub_key.name]
  firewall_ids = [hcloud_firewall.hrdp_fw.id]

  user_data = templatefile("templates/user_data.yaml", {
    hrdp_user_pass            = random_string.user_pass.result
    hrdp_user_authorized_keys = tls_private_key.client_keypair.public_key_openssh
    host_ecdsa_private        = indent(4, tls_private_key.host_keypair.private_key_pem)
    host_ecdsa_public         = tls_private_key.host_keypair.public_key_openssh
    xrdp_key                  = indent(6, tls_private_key.xrdp_keypair.private_key_pem)
    xrdp_cert                 = indent(6, tls_self_signed_cert.xrdp_cert.cert_pem)
  })
}

resource "local_file" "ssh_script" {
  content         = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = hcloud_server.hrdp_node.ipv4_address
  })
  filename        = "bin/ssh"
  file_permission = "700"
}

resource "null_resource" "wait_for_xrdp_socket" {
  provisioner "local-exec" {
    command = "while ! bin/ssh nc -z localhost 4489 &> /dev/null; do sleep 1; done"
  }
  depends_on = [hcloud_server.hrdp_node, local_file.ssh_script]
}

resource "local_file" "tun_script" {
  content         = templatefile("templates/tun.sh", {
    node_ip = hcloud_server.hrdp_node.ipv4_address
  })
  filename        = "bin/tun"
  file_permission = "700"
}

resource "local_file" "rdp_profile" {
  content         = templatefile("templates/conn.rdp", {
  })
  filename        = "session/conn.rdp"
  file_permission = "600"
}
