resource "oci_core_internet_gateway" "oci_igw" {
    #Required
    compartment_id      = oci_identity_compartment.compartment.id
    vcn_id              = oci_core_vcn.test_vcn.id
    display_name        = "oci_igw"

    route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oci_gateway.id
  }
}

resource "oci_core_route_table" "oci_igw_route_table" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "oci_igw_route_table"
  
  route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oci_igw.id
  }
} 