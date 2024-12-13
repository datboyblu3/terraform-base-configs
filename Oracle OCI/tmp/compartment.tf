# Create the OCI Compartment
resource "oci_identity_compartment" "sliver_test" {
  compartment_id = var.oci_root_compartment
  description    = "Compartment for appname resources"
  name           = "sliver_test"
  enable_delete  = true
}