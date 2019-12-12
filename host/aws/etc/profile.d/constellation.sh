#!/bin/sh

# Constellation Pharma shared shell configuration.
# Updated 2019-12-12 by Michael Steinbaugh.



# Notes                                                                     {{{1
# ==============================================================================

# Do not set 'LD_LIBRARY_PATH'.
# Use '/etc/ld.so.conf.d/' method instead.
# Run 'sudo ldconfig' to update shared libraries.

# Do not set 'R_HOME' or 'JAVA_HOME'.



# Koopa                                                                     {{{1
# ==============================================================================

# > export KOOPA_TEST=1
export KOOPA_USERS_NO_EXTRA="bioinfo barbara.bryant"
export KOOPA_USERS_SKIP="phil.drapeau"
