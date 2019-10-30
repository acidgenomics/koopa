#!/bin/sh

# Grep match here handles RStudio Server Pro version, which currently returns
# this warning in first line:
# # WARNING: ignoring environment value of R_HOME

R --version \
    | grep 'R version' \
    | cut -d ' ' -f 3
