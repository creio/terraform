variable "user_ocid" {}
variable "tenancy_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "instance_shape" {}
variable "subnet_ocid" {}
variable "image_ocid" {}
variable "ssh_public_key" {}
variable "ssh_pvt_key" {}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

variable "ad_region_mapping" {
  type = map(string)

  default = {
    eu-frankfurt-1 = 3
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_region_mapping[var.region]
}

resource "oci_core_instance" "free_instance0" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "ubarm"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = 24
    ocpus = 4
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "ubarm"
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key)}"
  }

  connection {
    user = "ubuntu"
    type = "ssh"
    host        = "${self.public_ip}"
    private_key = "${file(var.ssh_pvt_key)}"
  }

  ## Copy file
  provisioner "file" {
    source      = "./scripts/install.sh"
    destination = "/tmp/install.sh"
  }

  ## Run sh
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
    ]
  }
}

data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.free_instance0.id
}

data "oci_core_vnic" "app_vnic" {
  vnic_id = data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0]["vnic_id"]
}

output "app" {
  value = "public ip: ${data.oci_core_vnic.app_vnic.public_ip_address}"
}
