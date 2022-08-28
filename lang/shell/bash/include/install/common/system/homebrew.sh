#!/usr/bin/env bash

main() {
    # """
    # Install Homebrew.
    # @note Updated 2022-07-14.
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
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    declare -A dict
    dict['file']='install.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    if koopa_is_macos && [[ ! -d '/Library/Developer/CommandLineTools' ]]
    then
        koopa_macos_install_xcode_clt
    fi
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    "${app['sudo']}" -v
    NONINTERACTIVE=1 "./${dict['file']}" || true
    return 0
}
