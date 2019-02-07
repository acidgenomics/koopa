#!/usr/bin/env bash
set -Eeuo pipefail

# Global find and replace in files using sed.

pattern="$1"
replacement="$2"

if [[ -n "$MACOS" ]]
then
    find . -type f -exec sed -i "s/${pattern}/${replacement}/g" {} \;
elif [[ -n "$LINUX" ]]
then
    # Note the extra quotes in sed command here.
    find . -type f -exec sed -i "" "s/${pattern}/${replacement}/g" {} \;
fi
