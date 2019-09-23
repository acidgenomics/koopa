#!/bin/sh

# Include POSIX functions.
# Updated 2019-09-23.

# Use shell globbing instead of `find`, which doesn't support source.
for file in "${KOOPA_HOME}/shell/posix/functions/"*".sh"
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done
