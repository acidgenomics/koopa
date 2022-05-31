#!/usr/bin/env bash

main() {
    # """
    # Install FFmpeg.
    # @note Updated 2022-05-31.
    #
    # Consider also requiring:
    # - "aom"
    # - "dav1d"
    # - "fontconfig"
    # - "freetype"
    # - "frei0r"
    # - "gnutls"
    # - "libass"
    # - "libbluray"
    # - "librist"
    # - "libsoxr"
    # - "libvidstab"
    # - "libvmaf"
    # - "libvorbis"
    # - "libvpx"
    # - "opencore-amr"
    # - "openjpeg"
    # - "opus"
    # - "rav1e"
    # - "rubberband"
    # - "sdl2"
    # - "snappy"
    # - "speex"
    # - "srt"
    # - "tesseract"
    # - "theora"
    # - "webp"
    # - "x264"
    # - "x265"
    # - "xvid"
    # - "xz"
    # - "zeromq"
    # - "zimg"
    #
    # @seealso
    # - https://ffmpeg.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'lame'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='ffmpeg'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://ffmpeg.org/releases/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-x86asm'
        '--enable-pthreads'
        '--enable-shared'
        '--enable-version3'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
