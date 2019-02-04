#!/bin/sh

# Load secrets.

# shellcheck source=/dev/null
[ -f "${HOME}/.secrets" ] && . "${HOME}/.secrets"
