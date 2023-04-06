#!/usr/bin/env bash

main() {
    # """
    # Install Homebrew.
    # @note Updated 2023-03-24.
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
    local -A dict
    koopa_assert_has_no_args "$#"
    if [[ -x "$(koopa_locate_brew --allow-missing)" ]]
    then
        koopa_stop 'Homebrew is already installed.'
    fi
    if koopa_is_macos && [[ ! -d '/Library/Developer/CommandLineTools' ]]
    then
        koopa_stop \
            'Xcode Command Line Tools are not installed.' \
            "Run 'koopa install system xcode-clt' to resolve."
    fi
    dict['file']='install.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    NONINTERACTIVE=1 "./${dict['file']}" || true
    return 0
}
