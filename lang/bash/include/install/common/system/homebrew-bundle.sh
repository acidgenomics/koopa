#!/usr/bin/env bash

main() {
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2024-12-13.
    #
    # Custom brewfile is supported using a positional argument.
    #
    # Potentially problematic brew/cask link conflicts:
    # - emacs
    # - gnupg
    # - ranger
    # - vim
    # """
    local -A app dict
    local -a install_args
    if _koopa_is_macos
    then
        _koopa_macos_assert_is_xcode_clt_installed
    fi
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    dict['brewfile']="$(_koopa_xdg_config_home)/homebrew/brewfile"
    dict['prefix']="$(_koopa_homebrew_prefix)"
    _koopa_assert_is_dir "${dict['prefix']}"
    if [[ ! -f "${dict['brewfile']}" ]]
    then
        _koopa_stop "Brewfile at '${dict['brewfile']}' does not exist. \
Run 'koopa install dotfiles' and 'koopa configure user dotfiles' to resolve."
    fi
    # Note that cask specific args are handled by 'HOMEBREW_CASK_OPTS' global
    # variable, which is defined in our main Homebrew activation function.
    install_args=(
        # > '--debug'
        # > '--verbose'
        '--force'
        '--no-lock'
        '--no-upgrade'
        "--file=${dict['brewfile']}"
    )
    _koopa_dl 'Brewfile' "${dict['brewfile']}"
    _koopa_add_to_path_start "${dict['prefix']}/bin"
    _koopa_brew_reset_permissions
    "${app['brew']}" analytics off
    "${app['brew']}" bundle install "${install_args[@]}"
    _koopa_brew_doctor
    return 0
}
