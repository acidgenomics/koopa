#!/bin/sh

koopa_activate_perlbrew() {
    # """
    # Activate Perlbrew.
    # @note Updated 2022-05-12.
    #
    # Only attempt to autoload for bash or zsh.
    # Delete '~/.perlbrew' directory if you see errors at login.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    local nounset prefix script shell
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/perlbrew" ] || return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    prefix="$(koopa_perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
