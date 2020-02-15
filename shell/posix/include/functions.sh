#!/bin/sh

if [ -n "${BASH_VERSION:-}" ]
then
    KOOPA_POSIX_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]
then
    KOOPA_POSIX_SOURCE="${(%):-%N}"
else
    >&2 echo "ERROR: Unsupported shell."
    exit 1
fi

KOOPA_POSIX_INC="$(cd "$(dirname "$KOOPA_POSIX_SOURCE")" \
    >/dev/null 2>&1 && pwd -P)"

# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_POSIX_INC}/functions/"*".sh"
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done

unset -v KOOPA_POSIX_INC
