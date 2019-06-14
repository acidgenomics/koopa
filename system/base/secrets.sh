#!/bin/sh

# Load secrets.

# shellcheck source=/dev/null
if [ -f "${HOME}/.secrets" ]
then
    . "${HOME}/.secrets"
fi
