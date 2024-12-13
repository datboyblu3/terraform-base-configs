resource "oci_core_vcn" "tmp_oci_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "tmp_oci_vcn"
}

