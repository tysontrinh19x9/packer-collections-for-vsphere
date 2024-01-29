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
build_password           = "Ubuntu@packer"
build_password_encrypted = "$6$5aUxmPPoGKA6bfHF$58bT6EzrRmGbibjIQAxnesO59/hnMm5BQTW8qMme2wdo1KAvXIt1ua8DTZAexg5rEv2pESqb67VWG24q7xw6S."
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGkbIDM9uCe16Ynaq1p7g67Z4YGLZzT6NHe608uTboUjZCQGIOmgkvAjIF+DUa9vUcAa4uau9gNO8t92jS9bb3uLgAnaShm3V4/byvjdboOfgWgA6NzkdCa1SJgyzxmi5oIfOTi/l4NAk8ZM1S2N/QQJMADwgWjoLCOoVhA5QTy/coreQ== ubuntu@vsphere.local"