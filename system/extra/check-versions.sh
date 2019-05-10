#!/bin/sh

# Check for supported dependency versions.

check="Rscript --vanilla ${EXTRA_DIR}/check-version.R"



# Python                                                                    {{{1
# ==============================================================================

# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.

version="$(python --version 2>&1 | head -n 1 | cut -d " " -f 2)"
required_version="3.7"

$check "python" "$version" "$required_version"



# Vim                                                                       {{{1
# ==============================================================================

version="$(vim --version | head -1 | cut -d " " -f 5)"
required_version="8.1"

$check "vim" "$version" "$required_version"



unset -v check required_version version



# turn on folds
# vim: fdm=marker
