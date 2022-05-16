#!/bin/sh

koopa_activate_broot() { # {{{1
    # """
    # Activate broot directory tree utility.
    # @note Updated 2022-05-12.
    #
    # The br function script must be sourced for activation.
    # See 'broot --install' for details.
    #
    # Configuration file gets saved at '${prefs_dir}/conf.toml'.
    # Fish: launcher/fish/br.sh (also saved in Fish functions)
    #
    # Note that for macOS, we're assuming installation via Homebrew.
    # If installed as crate, it will use the same path as for Linux.
    #
    # @seealso
    # https://github.com/Canop/broot
    # """
    local config_dir nounset script shell
    [ -x "$(koopa_bin_prefix)/broot" ] || return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    config_dir="${HOME:?}/.config/broot"
    [ -d "$config_dir" ] || return 0
    # This is supported for Bash and Zsh.
    script="${config_dir}/launcher/bash/br"
    [ -f "$script" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
