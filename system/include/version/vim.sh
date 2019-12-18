#!/bin/sh

major="$( \
    vim --version \
    | head -n 1 \
    | cut -d ' ' -f 5 \
)"

patch="$( \
    vim --version \
    | grep 'Included patches:' \
    | cut -d '-' -f 2 \
)"

if [ -n "$patch" ]
then
    version="${major}.${patch}"
else
    version="${major}"
fi

echo "$version"
