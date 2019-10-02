#!/bin/sh

# Note that final step removes '-N' patch, which only applies to RStudio Server
# Pro release version.

rstudio-server version | \
    head -n 1 | \
    cut -d ' ' -f 1 | \
    cut -d '-' -f 1
