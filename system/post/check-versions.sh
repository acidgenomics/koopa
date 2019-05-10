#!/bin/sh

# Check for supported dependency versions.



# Python                                                                    {{{1
# ==============================================================================

# Requiring >= 3.
# Python 2.7 is phased out in 2020.
# The user can use either conda or virtualenv.

version="$(python --version 2>&1 | head -n 1 | cut -d " " -f 2)"
major_version="$(printf '%s' $version | cut -c 1)"
required_version="3"

if [ "$major_version" -lt "$required_version" ]
then
    echo "python ${version} < ${required_version}"
    echo "Consider using a virtualenv or conda."
fi

unset -v major_version required_version version



# Vim                                                                       {{{1
# ==============================================================================

version="$(vim --version | head -1 | cut -d " " -f 5)"
major_version="$(printf '%s' $version | cut -c 1)"
required_version="8"

if [ "$major_version" -lt "$required_version" ]
then
    echo "vim ${version} < ${required_version}"
fi

unset -v major_version required_version version


# turn on folds
# vim: fdm=marker
