resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "pvtKey.pem"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = file("private_key.pem")

  subject {
    common_name  = var.dns_name
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = var.validity

  allowed_uses = [
    "decipher_only",
    "digital_signature",
    "server_auth",
    "ipsec_user"
  ]
}

/*
# ECDSA key along with P384 elliptic curve
resource "tls_private_key" "private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

# ED25519 key
resource "tls_private_key" "private_key" {
  algorithm = "ED25519"
}
*/