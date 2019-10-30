#!/bin/sh

perl --version \
    | sed -n '2p' \
    | grep -Eo "v[.0-9]+" \
    | sed 's/^v//'
