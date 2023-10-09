#!/usr/bin/env bash

main() {
    # """
    # Install FFmpeg.
    # @note Updated 2023-10-09.
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
    # The new linker leads to duplicate symbol issue.
    # https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    if koopa_is_macos
    then
        dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
        if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
        then
            koopa_append_ldflags '-Wl,-ld_classic'
        fi
    fi
    dict['url']="https://ffmpeg.org/releases/ffmpeg-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
