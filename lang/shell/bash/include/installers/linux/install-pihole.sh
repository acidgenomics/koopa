#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Need to prefix this with Raspbian.
# FIXME Needs a corresponding updater.
# FIXME Needs a corresponding uninstaller.
# FIXME This also works on Ubuntu, so consider moving.

koopa:::linux_install_pihole() { # {{{1
    # """
    # Install Pi-hole.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://pi-hole.net
    # - https://github.com/pi-hole/pi-hole/#one-step-automated-install
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [file]='pihole.sh'
        [url]='https://install.pi-hole.net'
    )
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    "./${dict[file]}"
    return 0
}
