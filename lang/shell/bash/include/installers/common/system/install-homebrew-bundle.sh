#!/usr/bin/env bash

# FIXME Need to link emacs cask into /opt/koopa/bin.

main() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2022-01-31.
    #
    # Custom brewfile is supported using a positional argument.
    #
    # Potentially problematic brew/cask link conflicts:
    # - emacs
    # - gnupg
    # - ranger
    # - vim
    # """
    local app brewfile brewfiles dict install_args
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [local_brewfile]="$(koopa_xdg_config_home)/homebrew/brewfile"
    )
    brewfiles=()
    if koopa_is_linux
    then
        brewfiles+=(
            "${dict[koopa_prefix]}/os/linux/common/etc/homebrew/brewfile"
        )
    elif koopa_is_macos
    then
        brewfiles+=(
            "${dict[koopa_prefix]}/os/macos/etc/homebrew/brewfile"
        )
    fi
    brewfiles+=(
        "${dict[koopa_prefix]}/etc/homebrew/brewfile"
    )
    if [[ -f "${dict[local_brewfile]}" ]]
    then
        brewfiles+=("${dict[local_brewfile]}")
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
        koopa_assert_is_file "$brewfile"
        koopa_dl 'Brewfile' "$brewfile"
        "${app[brew]}" bundle install \
            "${install_args[@]}" \
            --file="${brewfile}"
    done
    return 0
}
