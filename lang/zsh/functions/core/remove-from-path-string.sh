#!/usr/bin/env zsh

_koopa_remove_from_path_string() {
    local str1="${1:?}"
    local dir="${2:?}"
    local str2
    str2="$( \
        _koopa_print "$str1" \
            | awk -v d="$dir" \
                'BEGIN { FS=":"; OFS=":" }
                {
                    n=0
                    for (i=1; i<=NF; i++) {
                        if ($i != d) {
                            if (n++) printf "%s", OFS
                            printf "%s", $i
                        }
                    }
                    printf "\n"
                }' \
        )"
    [[ -n "$str2" ]] || return 1
    _koopa_print "$str2"
    return 0
}
