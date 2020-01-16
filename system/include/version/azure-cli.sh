#!/bin/sh

az --version \
    | head -n 1 \
    | grep -Eo '[0-9]\.[0-9]\.[0-9]'
