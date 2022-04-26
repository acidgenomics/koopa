#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2022-04-22.
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
    koopa_link_in_bin "$(koopa_homebrew_prefix)/Homebrew/bin/brew" 'brew'
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
        [[ -f "$brewfile" ]] || continue
        koopa_dl 'Brewfile' "$brewfile"
        "${app[brew]}" bundle install \
            "${install_args[@]}" \
            --file="${brewfile}"
    done
    if koopa_is_macos
    then
        koopa_macos_link_homebrew
    fi
    return 0
}
