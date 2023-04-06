#!/usr/bin/env bash

main() {
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2022-10-06.
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
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    dict['brewfile']="$(koopa_xdg_config_home)/homebrew/brewfile"
    koopa_assert_is_file "${dict['brewfile']}"
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
    koopa_dl 'Brewfile' "${dict['brewfile']}"
    "${app['brew']}" analytics off
    "${app['brew']}" bundle install "${install_args[@]}"
    return 0
}
