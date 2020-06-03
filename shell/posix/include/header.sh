#!/bin/sh
# shellcheck disable=SC2039

# """
# POSIX shared header script.
# @note Updated 2020-06-03.
# """

if [ -z "${KOOPA_PREFIX:-}" ]
then
    >&2 printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset."
    exit 1
fi

# Source POSIX functions.
# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_PREFIX}/shell/posix/functions/"*".sh"
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done

# FIXME NEED TO PUT SCRIPTS IN PATH.
# FIXME CHECK IF KOOPA IS ALREADY IN PATH AND SKIP OTHERWISE.
