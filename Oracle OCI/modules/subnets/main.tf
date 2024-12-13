resource "oci_core_vcn" "tmp_public_oci_vcn" {
  cidr_block     = "192.168.1.0/24"
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "tmp_public_oci_vcn"

  route_table_id    = oci_core_route_table.igw_route_table.id
security_list_ids = [oci_core_security_list.public_security_list.id]
}

resource "oci_core_vcn" "tmp_private_oci_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "tmp_private_oci_vcn"
}



