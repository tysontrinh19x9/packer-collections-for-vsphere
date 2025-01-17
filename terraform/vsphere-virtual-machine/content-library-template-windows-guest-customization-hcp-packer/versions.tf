##################################################################################
# VERSIONS
##################################################################################

terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.100.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.10.0"
    }
  }
  required_version = ">= 1.10.0"
}
