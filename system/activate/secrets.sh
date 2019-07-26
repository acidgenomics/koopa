#!/bin/sh

## Load secrets.
## Updated 2019-06-26.

## shellcheck source=/dev/null
if [ -f "${HOME}/.secrets" ]
then
    . "${HOME}/.secrets"
fi
