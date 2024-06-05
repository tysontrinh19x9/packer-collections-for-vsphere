# Copyright 2023 VMware, Inc. All rights reserved
# SPDX-License-Identifier: BSD-2

/*
    DESCRIPTION:
    Build account variables used for all builds.
    - Variables are passed to and used by guest operating system configuration files (e.g., ks.cfg, autounattend.xml).
    - Variables are passed to and used by configuration scripts.
*/

// Default Account Credentials
build_username           = "debian"
build_password           = "naibed"
build_password_encrypted = "$6$Musgfu/T$XSsyO2YXUKrRjkvPo6yMJoTuaVUwFTw5ykyfiGP/jQqK6M890SBv9zQWcwqstFBiwWiQbQFBC8sbMTSywsVJi/"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABEuiOKU29kKYoz9xfw/QHn1SgakYs/1eR9vqY3CIFuN0svlwuV3GEbwM4LPDHld/DmRF4IIufxdMazXIBtuT9InQBwU8IXT4DYhFaUWHVM0Z2EOXBywT1bRxuTYeR89e5oDTKKkKVDb0nolpkfgrXTbw/zLV+kGuy5pFz+s1xHeKNNGA== debian@vsphere.local"