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
    app['brew']="$(_koopa_locate_brew --allow-missing)"
    if [[ -x "${app['brew']}" ]]
    then
        _koopa_stop 'Homebrew is already installed.'
    fi
    if _koopa_is_macos
    then
        _koopa_macos_assert_is_xcode_clt_installed
    fi
    dict['file']='install.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    _koopa_download "${dict['url']}" "${dict['file']}"
    _koopa_chmod 'u+x' "${dict['file']}"
    _koopa_sudo_trigger
    NONINTERACTIVE=1 "./${dict['file']}"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_brew_reset_permissions
    _koopa_brew_doctor
    return 0
}
