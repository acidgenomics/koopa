#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2021-11-22.
    #
    # @seealso
    # - https://docs.brew.sh/Installation
    # - https://github.com/Homebrew/legacy-homebrew/issues/
    #       46779#issuecomment-162819088
    # - https://github.com/Linuxbrew/brew/issues/556
    #
    # macOS:
    # NOTE This function won't run on macOS clean install due to very old Bash.
    # Installs to '/usr/local' on Intel and '/opt/homebrew' on Apple Silicon.
    #
    # Linux:
    # Creates a new linuxbrew user and installs to /home/linuxbrew/.linuxbrew.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [yes]="$(koopa_locate_yes)"
    )
    declare -A dict
    dict[file]='install.sh'
    dict[url]="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict[file]}"
    if koopa_is_macos
    then
        koopa_macos_install_xcode_clt
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "${app[yes]}" | "./${dict[file]}" || true
    return 0
}
