provider "oci" {
  tenancy_ocid          = "<your_tenancy_ocid>"
  user_ocid             = "<your_user_ocid>"
  fingerprint           = "<your_fingerprint>"
  private_key_path      = "<path_to_your_private_key>"
  region                = "<your_region>"  # Example: "us-ashburn-1"
}

resource "oci_core_vcn" "example_vcn" {
  cidr_block   = "10.0.0.0/16"
  display_name = "example-vcn"
  compartment_id = "<your_compartment_ocid>"
}

resource "oci_core_internet_gateway" "example_igw" {
  display_name   = "example-igw"
  is_enabled     = true
  vcn_id         = oci_core_vcn.example_vcn.id
  compartment_id = "<your_compartment_ocid>"
}

resource "oci_core_route_table" "example_route_table" {
  vcn_id = oci_core_vcn.example_vcn.id

  route_rules = [
    {
      cidr_block      = "0.0.0.0/0"
      network_entity_id = oci_core_internet_gateway.example_igw.id
    }
  ]
}

resource "oci_core_subnet" "example_subnet" {
  vcn_id              = oci_core_vcn.example_vcn.id
  cidr_block          = "10.0.1.0/24"
  display_name        = "example-subnet"
  compartment_id      = "<your_compartment_ocid>"
  prohibit_public_ip_on_vnic = false
  route_table_id      = oci_core_route_table.example_route_table.id
}

resource "oci_core_security_list" "example_security_list" {
  display_name   = "example-security-list"
  compartment_id = "<your_compartment_ocid>"
  vcn_id         = oci_core_vcn.example_vcn.id

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
    }
  ]

  ingress_security_rules = [
    {
      protocol      = "6" # TCP
      source        = "0.0.0.0/0"
      tcp_options = {
        "min" = 22
        "max" = 22
      }
    }
  ]
}

resource "oci_core_instance" "example_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = "<your_compartment_ocid>"
  display_name        = "example-instance"
  shape               = "VM.Standard.E2.1" # Choose your shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.example_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub") # Path to your public key
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.default_image.id
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "<your_compartment_ocid>"
}

data "oci_core_images" "default_image" {
  compartment_id = "<your_compartment_ocid>"
  operating_system = "Oracle Linux"
  operating_system_version = "8"
}
