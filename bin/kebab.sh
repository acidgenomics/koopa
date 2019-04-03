#!/usr/bin/env bash
set -Eeuo pipefail

# Kebab case
#
# See also:
# - https://stackoverflow.com/questions/152514
# - https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html

# Error if user does not have Perl rename installed.
if [[ $(rename -V | grep -c "File::Rename") -eq 0 ]]
then
    echo "This script requires Perl rename (File::Rename)."
    exit 1
fi

# Set IFS so we can process files containing spaces.
ifs=$IFS
IFS=$(echo -en "\n\b")

files=($@)

# printf "%s\n" "${files[@]}"

for file in "${files[@]}"
do
    # Convert underscores and spaces to dashes.
    rename 's/[_\s]/-/g' "$file"

    # Using `-f` flag here for case insensitive filesystem support (macOS).
    # rename -f 'y/A-Z/a-z/' "$file"

    # Ensure R scripts end with capital `.R`.
    # FIXME Improve the file pattern matching here.
    # rename 's/\.r$/.R' "$file"
done

IFS=$ifs
unset -v ifs
