#!/usr/bin/env bash

main() {
    # """
    # Install rclone.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://rclone.org/
    # - https://github.com/rclone/rclone/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/rclone.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/rclone/rclone/archive/v1.62.2.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    dict['ldflags']="-s -w -X github.com/rclone/rclone/fs.Version=v${dict['version']}"
    koopa_print_env
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/rclone"
    koopa_cp \
        --target-directory="${dict['prefix']}/share/man/man1" \
        'rclone.1'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
