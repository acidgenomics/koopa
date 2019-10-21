#!/bin/sh

openssl version        \
    | head -n 1        \
    | cut -d ' ' -f 2  \
    | cut -d '-' -f 1
