#!/usr/bin/env zsh

_koopa_activate_starship() {
    local starship
    starship="${KOOPA_PREFIX:?}/bin/starship"
    if [[ ! -x "$starship" ]]
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
    if [[ -n "${STARSHIP_SHELL:-}" ]] && [[ "$STARSHIP_SHELL" != "$shell" ]]
    then
        unset -v STARSHIP_SHELL
    fi
    export STARSHIP_LOG='error'
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/starship-${shell}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$starship" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$starship" init "$shell" > "$cache_file"
    fi
    source "$cache_file"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
