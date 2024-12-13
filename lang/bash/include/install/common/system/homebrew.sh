#!/usr/bin/env bash

main() {
    # """
    # Install Homebrew.
    # @note Updated 2024-12-13.
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
    local -A app dict
    app['brew']="$(koopa_locate_brew --allow-missing)"
    if [[ -x "${app['brew']}" ]]
    then
        koopa_stop 'Homebrew is already installed.'
    fi
    if koopa_is_macos
    then
        koopa_macos_assert_is_xcode_clt_installed
    fi
    dict['file']='install.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    koopa_sudo_trigger
    NONINTERACTIVE=1 "./${dict['file']}"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    koopa_brew_reset_permissions
    koopa_brew_doctor
    return 0
}
