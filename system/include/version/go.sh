#!/bin/sh

go version \
    | grep -Eo "go[.0-9]+" \
    | cut -c 3-

