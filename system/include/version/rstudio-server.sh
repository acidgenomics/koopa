#!/bin/sh

rstudio-server version | \
    head -n 1 | \
    cut -d ' ' -f 1
