resource "hcloud_firewall" "hrdp_fw" {
  name = "hrdp-${random_string.session_id.result}"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}
