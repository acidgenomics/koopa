#!/usr/bin/env bash

main() {
    # """
    # Install FFmpeg.
    # @note Updated 2023-10-04.
    #
    # @seealso
    # - https://ffmpeg.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'lame'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        '--disable-x86asm'
        '--enable-libmp3lame'
        '--enable-pthreads'
        '--enable-shared'
        '--enable-version3'
        "--prefix=${dict['prefix']}"
    )
    if koopa_is_macos
    then
        # The new linker leads to duplicate symbol issue.
        # https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
        LDFLAGS="${LDFLAGS:-}"
        LDFLAGS="-Wl,-ld_classic ${LDFLAGS}"
        export LDFLAGS
    fi
    dict['url']="https://ffmpeg.org/releases/ffmpeg-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
