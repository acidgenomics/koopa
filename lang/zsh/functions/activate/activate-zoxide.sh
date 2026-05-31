#!/usr/bin/env zsh

_koopa_activate_zoxide() {
    local zoxide
    zoxide="${KOOPA_PREFIX:?}/bin/zoxide"
    if [[ ! -x "$zoxide" ]]
    then
        return 0
    fi
    local shell
    shell="${KOOPA_SHELL##*/}"
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    case "$shell" in
        'bash' | \
        'zsh')
            local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/zoxide-${shell}.sh"
            if [[ ! -f "$cache_file" ]] || [[ "$zoxide" -nt "$cache_file" ]]; then
                mkdir -p "${cache_file%/*}"
                "$zoxide" init "$shell" > "$cache_file"
            fi
            source "$cache_file"
            unalias z 2>/dev/null || true
            ;;
        *)
            eval "$("$zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
