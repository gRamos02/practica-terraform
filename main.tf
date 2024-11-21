terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = var.region //En parte 1 hardcodear 
  auth                = "SecurityToken"
  config_file_profile = "aprendiendo-terraform"
}

resource "oci_core_vcn" "internal" {
  dns_label      = "internal"
  cidr_block     = "172.16.0.0/20"
  compartment_id = var.compartment_id //En parte 1 hardcodear 
  display_name   = "Mi VCN con terraform"
}


//Parte 2, crear una subred
resource "oci_core_subnet" "dev" {
  vcn_id                     = oci_core_vcn.internal.id
  cidr_block                 = "172.16.0.0/24"
  compartment_id = var.compartment_id //En parte 1 hardcodear 
  display_name               = "subred"
  prohibit_public_ip_on_vnic = false 
  dns_label                  = "dev"
}

// Fetch availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id 
}
//Crear instancia
resource "oci_core_instance" "ubuntu_instance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = var.compartment_id
    shape = "VM.Standard2.1"
    source_details {
        source_id = "ocid1.image.oc1.iad.aaaaaaaazratqczukgd5m5x265gfbk46cvfmkytffvidggghvj4j2ttyu6tq"
        source_type = "image"
    }

    # Optional
    display_name = "Mi instancia con terraform"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.dev.id 
    }
    metadata = {
        ssh_authorized_keys = file("terraform-key.pub")
    } 
    preserve_boot_volume = false
}