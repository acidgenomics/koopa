#!/usr/bin/env bash

_koopa_major_minor_patch_version() {
    local str
    _koopa_is_alias 'cut' && unalias 'cut'
    for str in "$@"
    do
        str="$( \
            _koopa_print "$str" \
            | cut -d '.' -f '1-3' \
        )"
        [[ -n "$str" ]] || return 1
        str="$( \
            _koopa_print "$str" \
            | cut -d '-' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        str="$( \
            _koopa_print "$str" \
            | cut -d 'p' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}
