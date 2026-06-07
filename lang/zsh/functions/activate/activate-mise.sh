#!/usr/bin/env zsh

_koopa_activate_mise() {
    local mise
    mise="${KOOPA_PREFIX:?}/bin/mise"
    if [[ ! -x "$mise" ]]
    then
        return 0
    fi
    local shell
    shell="${KOOPA_SHELL##*/}"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/mise-${shell}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$mise" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$mise" activate "$shell" > "$cache_file"
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$cache_file"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
