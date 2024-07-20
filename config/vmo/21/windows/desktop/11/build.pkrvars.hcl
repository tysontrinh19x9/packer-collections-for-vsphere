# Copyright 2023-2024 Broadcom. All rights reserved.
# SPDX-License-Identifier: BSD-2

/*
    DESCRIPTION:
    Build account variables used for all builds.
    - Variables are passed to and used by guest operating system configuration files (e.g., ks.cfg, autounattend.xml).
    - Variables are passed to and used by configuration scripts.
*/

// Default Account Credentials
build_username           = "vmware"
build_password           = "vmware"
build_password_encrypted = "$6$wC6ecocj$vyIcCxH9.xSfDaVnCvTmZe01ur1b0GuLlxCF5JSHjxC70gRBV2x7Lj8HdkWV1U3HkXjguPgB1Ofoq9eSCaanH/"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABEuiOKU29kKYoz9xfw/QHn1SgakYs/1eR9vqY3CIFuN0svlwuV3GEbwM4LPDHld/DmRF4IIufxdMazXIBtuT9InQBwU8IXT4DYhFaUWHVM0Z2EOXBywT1bRxuTYeR89e5oDTKKkKVDb0nolpkfgrXTbw/zLV+kGuy5pFz+s1xHeKNNGA== windows@vsphere.local"
