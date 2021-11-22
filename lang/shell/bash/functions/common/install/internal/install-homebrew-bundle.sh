#!/usr/bin/env bash

koopa:::install_homebrew_bundle() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2021-11-22.
    #
    # Custom brewfile is supported using a positional argument.
    # """
    local app brewfile brewfiles dict install_args
    koopa::assert_is_admin
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa::koopa_prefix)"
    )
    if [[ "$#" -eq 0 ]]
    then
        brewfiles=()
        if koopa::is_linux
        then
            brewfiles+=(
                "${dict[koopa_prefix]}/os/linux/common/etc/homebrew/brewfile"
            )
        elif koopa::is_macos
        then
            brewfiles+=(
                "${dict[koopa_prefix]}/os/macos/etc/homebrew/brewfile"
            )
        fi
        brewfiles+=(
            "${dict[koopa_prefix]}/etc/homebrew/brewfile"
        )
    else
        brewfiles=("$@")
    fi
    "${app[brew]}" analytics off
    # Note that cask specific args are handled by 'HOMEBREW_CASK_OPTS' global
    # variable, which is defined in our main Homebrew activation function.
    install_args=(
        # > '--debug'
        # > '--verbose'
        '--force'
        '--no-lock'
        '--no-upgrade'
    )
    for brewfile in "${brewfiles[@]}"
    do
        koopa::assert_is_file "$brewfile"
        koopa::dl 'Brewfile' "$brewfile"
        "${app[brew]}" bundle install \
            "${install_args[@]}" \
            --file="${brewfile}"
    done
    return 0
}
