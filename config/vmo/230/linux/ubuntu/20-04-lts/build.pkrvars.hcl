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
build_password_encrypted = "$6$rounds=4096$fVGIXjwzdGHxN5pE$Ff9p.uzwQLFSEcG5ZvM2DKz2On9FNzbwlBxzw4iqQcC8TbJ6HjMqjcvHZROI5IwIlIJHGmnIi42mDtqcCLEk11"
build_key                = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAC1xIZk58F+aDWPnBsDzYK4dnwY/IWk5oqTKvBalxOuUuXUd33LcAEIYJHY+hNrhT/pmdDm24VWGnCTk12otCC4WwGvpKWUEDolTEE1hjmGcaXg0b9sIF7NA+Gqq0cuy7VpIXJg4JbDF8pb3gyzxaLZWrDpgj2j7SGXDgnBv3hF+46UcA== admin@linux"
