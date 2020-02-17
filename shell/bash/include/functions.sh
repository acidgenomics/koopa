#!/usr/bin/env bash

KOOPA_BASH_INC="$(cd "$(dirname "${BASH_SOURCE[0]}")" \
    >/dev/null 2>&1 && pwd -P)"

# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_BASH_INC}/../functions/"*".sh"
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done

unset -v KOOPA_BASH_INC
