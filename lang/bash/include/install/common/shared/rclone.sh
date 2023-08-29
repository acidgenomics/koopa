#!/usr/bin/env bash

main() {
    # """
    # Install rclone.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://rclone.org/
    # - https://github.com/rclone/rclone/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/rclone.rb
    # """
    local -A dict
    local -a ldflags
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/rclone/rclone/archive/\
v${dict['version']}.tar.gz"
    ldflags=(
        '-s' '-w' '-X'
        "github.com/rclone/rclone/fs.Version=v${dict['version']}"
    )
    dict['ldflags']="${ldflags[*]}"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='rclone' \
        -D "--ldflags=${dict['ldflags']}" \
        -D "--url=${dict['url']}"
    koopa_cp \
        --target-directory="${dict['prefix']}/share/man/man1" \
        'rclone.1'
    return 0
}
