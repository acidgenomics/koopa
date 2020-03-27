#!/bin/sh
# shellcheck disable=SC2039

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

# Disable user-defined aliases.
# Primarily intended to reset cp, mv, rf for use inside scripts.
unalias -a
