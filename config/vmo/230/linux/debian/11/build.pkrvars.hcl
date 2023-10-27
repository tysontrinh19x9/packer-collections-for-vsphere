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
build_password_encrypted = "$6$rounds=4096$8z6U4Ouyv3op488y$4jFgCThnbn/PWzPGFtnwZXNaFCRp9ofofVSak2QPW.VOmfiZsVSXyWyh8oHl7w9LpgDKLE/cgnJypnvCl1LbT1"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAC1xIZk58F+aDWPnBsDzYK4dnwY/IWk5oqTKvBalxOuUuXUd33LcAEIYJHY+hNrhT/pmdDm24VWGnCTk12otCC4WwGvpKWUEDolTEE1hjmGcaXg0b9sIF7NA+Gqq0cuy7VpIXJg4JbDF8pb3gyzxaLZWrDpgj2j7SGXDgnBv3hF+46UcA== debian@linux"
