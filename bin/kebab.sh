#!/usr/bin/env bash
set -Eeuo pipefail

# Kebab case
#
# See also:
# - https://stackoverflow.com/questions/152514

# Error if user does not have Perl rename installed.
if [[ $(rename -V | grep -c "File::Rename") -eq 0 ]]
then
    echo "This script requires Perl rename (File::Rename)."
    exit 1
fi

# Using `-f` flag here for case insensitive filesystem support (macOS).
rename -f 'y/A-Z/a-z/' *

# Convert underscores and spaces to dashes.
rename 's/[_\s]/-/g' *
