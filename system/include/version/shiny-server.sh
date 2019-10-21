#!/bin/sh

shiny-server --version  \
    | head -n 1         \
    | cut -d ' ' -f 3   \
    | sed 's/^v//'
