#!/bin/sh

x="$(rename --version | head -n 1)"

# Check for Perl rename.
if ! echo "$x" | grep -q 'File::Rename'
then
    _acid_stop "Perl File::Rename is not installed."
fi

echo "$x" | cut -d ' ' -f 5
