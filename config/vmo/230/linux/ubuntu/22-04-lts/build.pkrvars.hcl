# Copyright 2023 VMware, Inc. All rights reserved
# SPDX-License-Identifier: BSD-2

/*
    DESCRIPTION:
    Build account variables used for all builds.
    - Variables are passed to and used by guest operating system configuration files (e.g., ks.cfg, autounattend.xml).
    - Variables are passed to and used by configuration scripts.
*/

// Default Account Credentials
build_username           = "admin"
build_password           = "nimda"
build_password_encrypted = "$6$j0yDGwK.oNM6E2RL$VMcGTeRcvBhFO3ivdjec7vnW9No3hg/od4qrqshGoJYUss7yFDVdOqI5iEd2F.SJxE24ASgw3rtMgGD16StF2/"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGkbIDM9uCe16Ynaq1p7g67Z4YGLZzT6NHe608uTboUjZCQGIOmgkvAjIF+DUa9vUcAa4uau9gNO8t92jS9bb3uLgAnaShm3V4/byvjdboOfgWgA6NzkdCa1SJgyzxmi5oIfOTi/l4NAk8ZM1S2N/QQJMADwgWjoLCOoVhA5QTy/coreQ== admin@vsphere.local"
