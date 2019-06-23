#!/bin/sh

# Include POSIX functions.
# Modified 2019-06-20.



# > set -a

# Use shell globbing instead of `find`, which doesn't support source.
for file in "${KOOPA_HOME}/system/include/functions/"*".sh"
do
    [ -f "$file" ] && . "$file"
done

# > set +a
