resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nat_gateway"
}