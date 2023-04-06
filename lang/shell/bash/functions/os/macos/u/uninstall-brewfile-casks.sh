#!/usr/bin/env bash

koopa_macos_uninstall_brewfile_casks() {
    # """
    # Delete macOS applications installed by Homebrew cask.
    # @note 2023-04-05.
    #
    # This step is useful for reinstalling Homebrew on a system with
    # casks previously installed, which don't get cleaned up currently.
    #
    # @usage koopa_macos_homebrew_uninstall_brewfile_casks FILE
    #
    # @examples
    # > koopa_macos_homebrew_uninstall_brewfile_casks \
    #>      /opt/koopa/os/macos/etc/homebrew/brewfile
    # """
    local -A app dict
    local -a casks
    local cask
    koopa_assert_has_args_eq "$#" 1
    app['brew']="$(koopa_locate_brew)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['brewfile']="${1:?}"
    readarray -t casks <<< "$( \
        koopa_grep \
            --file="${dict['brewfile']}" \
            --pattern='^cask\s"' \
            --regex \
        | "${app['cut']}" -d '"' -f '2' \
    )"
    for cask in "${casks[@]}"
    do
        "${app['brew']}" uninstall --cask --force "$cask"
    done
    return 0
}
