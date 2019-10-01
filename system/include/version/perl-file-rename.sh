#!/bin/sh

x="$(rename --version | head -n 1)"

# Check for Perl rename.
if ! echo "$x" | grep -q 'File::Rename'
then
    >&2 printf "Error: Not installed: Perl File::Rename.\n"
    exit 1
fi

echo "$x" | cut -d ' ' -f 5
