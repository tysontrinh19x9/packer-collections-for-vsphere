# Copyright 2023 VMware, Inc. All rights reserved
# SPDX-License-Identifier: BSD-2

/*
    DESCRIPTION:
    Build account variables used for all builds.
    - Variables are passed to and used by guest operating system configuration files (e.g., ks.cfg, autounattend.xml).
    - Variables are passed to and used by configuration scripts.
*/

// Default Account Credentials
build_username           = "ubuntu"
build_password           = "Ubuntu@2024"
build_password_encrypted = "$6$P7e8ZQbK$t6d9XOTALo77igQ0dQZx3H3E7Cd9I2cbAhrEWV94DClwF0DIwxL3rQEfZ8BFmXXwW5fIIVrTjgscUAfVulEt/1"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABEuiOKU29kKYoz9xfw/QHn1SgakYs/1eR9vqY3CIFuN0svlwuV3GEbwM4LPDHld/DmRF4IIufxdMazXIBtuT9InQBwU8IXT4DYhFaUWHVM0Z2EOXBywT1bRxuTYeR89e5oDTKKkKVDb0nolpkfgrXTbw/zLV+kGuy5pFz+s1xHeKNNGA== ubuntu@vsphere.local"