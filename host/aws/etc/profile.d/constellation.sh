#!/bin/sh

# Constellation Pharma AWS VM shared shell configuration.
# Updated 2020-01-14 by Michael Steinbaugh.



# Notes  {{{1
# ==============================================================================

# Do not set 'LD_LIBRARY_PATH'.
# Use '/etc/ld.so.conf.d/' method instead.
# Run 'sudo ldconfig' to update shared libraries.

# Do not set 'R_HOME' or 'JAVA_HOME'.



# Koopa  {{{1
# ==============================================================================

export KOOPA_CONFIG="constellation-aws"
export KOOPA_USERS_NO_EXTRA="barbara.bryant"
export KOOPA_USERS_SKIP="phil.drapeau"
