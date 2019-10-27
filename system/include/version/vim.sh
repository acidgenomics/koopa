#!/bin/sh

major="$(                                                                      \
    vim --version                                                              \
    | head -n 1                                                                \
    | cut -d ' ' -f 5                                                          \
)"

patch="$(                                                                      \
    vim --version                                                              \
    | grep 'Included patches:'                                                 \
    | cut -d '-' -f 2                                                          \
)"

printf "%s.%s\n" "$major" "$patch"
