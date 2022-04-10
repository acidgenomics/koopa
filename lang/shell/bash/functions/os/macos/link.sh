#!/usr/bin/env bash

koopa_macos_homebrew_uninstall_brewfile_casks() { # {{{1
    # """
    # Delete macOS applications installed by Homebrew cask.
    # @note 2022-04-09.
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
    local app cask casks dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict=(
        [brewfile]="${1:?}"
    )
    readarray -t casks <<< "$( \
        koopa_grep \
            --file="${dict[brewfile]}" \
            --pattern='^cask\s"' \
            --regex \
        | "${app[cut]}" --delimiter='"' --fields='2' \
    )"
    for cask in "${casks[@]}"
    do
        "${app[brew]}" uninstall --cask --force "$cask"
    done
    return 0
}

koopa_macos_link_homebrew() { # {{{1
    koopa_assert_has_no_args "$#"
    # BBEdit cask.
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    # Emacs cask.
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    # R cask.
    dict[r]="$(koopa_macos_r_prefix)"
    koopa_link_in_bin \
        "${dict[r]}/bin/R" 'R' \
        "${dict[r]}/bin/Rscript" 'Rscript'
    # Visual Studio Code cask.
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
}

koopa_macos_unlink_homebrew() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin \
        'R' \
        'Rscript' \
        'bbedit' \
        'code' \
        'emacs' \
        'gcloud' \
        'julia'
    return 0
}
