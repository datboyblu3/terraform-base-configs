resource "oci_core_vcn" "security_lab_vcn" {
  cidr_block     = var.vcn_cidr_block
  display_name   = "security-lab-vcn"
  compartment_id = var.compartment
}

resource "oci_core_internet_gateway" "security_lab_igw" {
  display_name   = var.gateway_name
  vcn_id         = oci_core_vcn.security_lab_vcn.id
  compartment_id = var.compartment
}

resource "oci_core_route_table" "security_lab_route_table" {
  vcn_id         = oci_core_vcn.security_lab_vcn.id
  compartment_id = var.compartment

  route_rules {
    destination        = var.route_table_cidr
    network_entity_id = oci_core_internet_gateway.security_lab_igw.id
  }
}

resource "oci_core_subnet" "security_lab_public_subnet" {
  vcn_id                     = oci_core_vcn.security_lab_vcn.id
  cidr_block                 = var.public_cidr_block
  display_name               = "security-lab-public-subnet"
  compartment_id             = var.compartment
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.security_lab_route_table.id
}

resource "oci_core_subnet" "security_lab_private_subnet" {
  vcn_id         = oci_core_vcn.security_lab_vcn.id
  cidr_block     = var.private_cidr_block
  display_name   = "security-lab-private-subnet"
  compartment_id = var.compartment
  route_table_id = oci_core_route_table.security_lab_route_table.id
}

resource "oci_core_security_list" "security_lab_fw" {
  display_name   = "security-lab-fw"
  compartment_id = var.compartment
  vcn_id         = oci_core_vcn.security_lab_vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_instance" "security_lab_instance" {
  availability_domain = data.oci_identity_availability_domains.security_lab_ad.availability_domains[0].name
  compartment_id      = var.compartment
  display_name        = "security-lab-instance"
  shape               = "VM.Standard2.8" # Choose your shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.security_lab_private_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/oci_key.pub") # Path to your public key
    user_data           = base64encode(<<-EOF
                            # Step 1: Install expect and change root password
                            yum install -y expect
                            cat << 'EOL1' > /root/change_root_password.exp
                            #!/usr/bin/expect
                            set timeout -1
                            spawn passwd root
                            expect "New password:"
                            send "ChangeMe\r"
                            expect "Retype new password:"
                            send "ChangeMe\r"
                            expect eof
                            EOL1
    
                            chmod +x /root/change_root_password.exp
                            /root/change_root_password.exp

                            # Step 2: Stop and disable firewalld, supplying the password
                            cat << 'EOL2' > /root/disable_firewalld.exp
                            #!/usr/bin/expect
                            set timeout -1
                            spawn systemctl stop firewalld
                            expect "Password for root:"
                            send "ChangeMe\r"
                            expect eof

                            spawn systemctl disable firewalld
                            expect "Password for root:"
                            send "ChangeMe\r"
                            expect eof
                            EOL2

                            chmod +x /root/disable_firewalld.exp
                            /root/disable_firewalld.exp
                          EOF
    )
  }

  source_details {
    source_type = "image"
    source_id   = var.source_id
  }

  provisioner "remote-exec" {
    inline = [
                "sudo yum install python39 -y"
             ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "opc"
      private_key = file("~/.ssh/oci_key")
    }
  }

 provisioner "local-exec" {
    working_dir = var.dir
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u opc -i '${self.public_ip},'  --private-key '~/.ssh/oci_key' -e '~/.ssh/oci_key.pub' sliver_beacon.yml -vvv"
  }

}

data "oci_identity_availability_domains" "security_lab_ad" {
  compartment_id = var.tenancy_ocid
}
