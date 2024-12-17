terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "6.20.0"
    }
  }
}

provider "oci" {
  tenancy_ocid          = var.tenancy_ocid
  user_ocid             = var.user_ocid
  fingerprint           = var.fingerprint
  private_key           = file("~/.oci/rsa_private.pem")
  region                = var.region
}