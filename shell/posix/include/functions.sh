#!/bin/sh

# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_PREFIX}/shell/posix/functions/"*".sh"
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done
