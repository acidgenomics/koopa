#!/usr/bin/env bash

# FIXME Currently failing to build with Xcode CLT 15.3:
# https://github.com/Homebrew/homebrew-core/blob/2fc9fa519f9dbcf9c973d5f60db164f491207f8d/Formula/s/sox.rb

# Likely need to apply this patch:
# https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff

# Build error:
# skelform.c:214:5: error: incompatible function pointer types initializing 'sox_format_handler_seek' (aka 'int (*)(struct sox_format_t *, unsigned long)') with an expression of type 'int (sox_format_t *, uint64_t)' (aka 'int (struct sox_format_t *, unsigned long long)') [-Wincompatible-function-pointer-types]
#     seek, encodings, NULL, sizeof(priv_t)
#     ^~~~
# 1 warning and 1 error generated.
# gmake[1]: *** [Makefile:1726: libsox_la-skelform.lo] Error 1

# Maybe related:
# https://gerrit.openbmc.org/plugins/gitiles/openbmc/openbmc/+/fc113eade321128fc43b0b299e81ad07fc1edf3d%5E%21/

main() {
    # """
    # Install SoX.
    # @note Updated 2024-06-16.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/sox
    # - https://ports.macports.org/port/sox/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'flac'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
        # Options enabled by MacPorts:
        # > --disable-openmp
        # > --disable-silent-libtool
        # > --disable-silent-rules
        # > --enable-largefile
        # > --enable-symlinks
        # > --with-distro=macosx
        # > --without-libltdl
        # Additional formats:
        # > --with-flac
        # > --with-gsm
        # > --with-id3tag
        # > --with-lame
        # > --with-lpc10
        # > --with-mad
        # > --with-magic
        # > --with-mp3
        # > --with-oggvorbis
        # > --with-opus
        # > --with-png
        # > --with-sndfile
        # > --with-twolame
        # > --with-wavpack
        # > --without-amrnb
        # > --without-amrwb
        # > --without-ladspa
        # Output drivers:
        # > --with-coreaudio
        # > --without-alsa
        # > --without-ao
        # > --without-oss
        # > --without-pulseaudio
        # > --without-sndio
        # > --without-sunaudio
        # > --without-waveaudio
    )
    dict['url']="https://downloads.sourceforge.net/project/sox/sox/\
${dict['version']}/sox-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
