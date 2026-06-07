#!/usr/bin/env zsh

_koopa_activate_atuin() {
    _koopa_is_root && return 0
    local atuin
    atuin="${KOOPA_PREFIX:?}/bin/atuin"
    if [[ ! -x "$atuin" ]]
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
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/atuin-${shell}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$atuin" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$atuin" init "$shell" --disable-up-arrow > "$cache_file"
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$cache_file"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
