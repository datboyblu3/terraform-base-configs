resource "oci_core_instance" "tmp_oci_instance" {
  availability_domain = "<your_availability_domain>"
  compartment_id      = "<your_compartment_ocid>"
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id = "<your_subnet_ocid>"
  }

  source_details {
    source_type = "image"
    source_id   = "<your_image_ocid>"
  }

 
}