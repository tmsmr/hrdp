resource "tls_private_key" "client_keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "client_pub_key" {
  name       = "hrdp-${random_string.session_id.result}"
  public_key = tls_private_key.client_keypair.public_key_openssh
}

resource "local_file" "client_priv_key" {
  content         = tls_private_key.client_keypair.private_key_pem
  filename        = "session/id_ecdsa"
  file_permission = "600"
}

resource "tls_private_key" "host_keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "local_file" "known_hosts" {
  content  = "${hcloud_server.hrdp_node.ipv4_address} ${tls_private_key.host_keypair.public_key_openssh}"
  filename = "session/known_hosts"
}

resource "tls_private_key" "xrdp_keypair" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "xrdp_cert" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.xrdp_keypair.private_key_pem
  validity_period_hours = 24 * 14
  allowed_uses          = ["server_auth"]

  subject {
    common_name = "hrdp-${random_string.session_id.result}"
  }
}

resource "local_file" "xrdp_cert" {
  content  = tls_self_signed_cert.xrdp_cert.cert_pem
  filename = "session/xrdp_cert"

  provisioner "local-exec" {
    command     = "openssl x509 -noout -fingerprint -sha1 -inform pem -in session/xrdp_cert | cut -d '=' -f 2 | tr -d '\n' > session/xrdp_cert.sha1"
  }

  provisioner "local-exec" {
    command     = "rm session/xrdp_cert.sha1"
    when        = destroy
  }
}

data "local_file" "xrdp_sha1" {
  filename   = "session/xrdp_cert.sha1"
  depends_on = [local_file.xrdp_cert]
}
