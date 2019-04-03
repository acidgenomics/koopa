#!/usr/bin/env bash
set -Eeuo pipefail

# Kebab case

# Error if user does not have Perl rename installed.
if [[ $(rename -V | grep -c "File::Rename") -eq 0 ]]
then
    echo "This script requires Perl rename (File::Rename)."
    exit 1
fi

rename 's/[_\s]/-/g' *
