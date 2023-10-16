# Copyright 2023 VMware, Inc. All rights reserved
# SPDX-License-Identifier: BSD-2

/*
    DESCRIPTION:
    VMware vSphere variables used for all builds.
    - Variables are use by the source blocks.
*/

// vSphere Credentials
vsphere_endpoint            = "10.0.255.238"
vsphere_username            = "administrator@vsphere.local"
vsphere_password            = "Tung199*"
vsphere_insecure_connection = true

// vSphere Settings
vsphere_datacenter = "VMO"
#vsphere_cluster    = "sfo-w01-cl01"
vsphere_host       = "10.0.255.230"
vsphere_datastore  = "SSD_2048_230"
vsphere_network    = "LAN"
vsphere_folder     = "Template"
