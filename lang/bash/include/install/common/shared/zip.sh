#!/usr/bin/env bash

# FIXME Need to provide a patch for xcode 15.
# https://github.com/Homebrew/homebrew-core/blob/6d56d2d5d09ea51fd3e1a5da801babff0e68ada3/Formula/z/zip.rb
# https://raw.githubusercontent.com/Homebrew/formula-patches/d2b59930/zip/xcode15.diff

main() {
    # """
    # Install zip.
    # @note Updated 2023-10-09.
    #
    # Upstream is unmaintained so we use the Debian patchset:
    # https://packages.debian.org/sid/zip
    #
    # @seealso
    # - http://infozip.sourceforge.net/Zip.html
    # - http://ftp.debian.org/debian/pool/main/z/zip/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zip.rb
    # - https://git.alpinelinux.org/aports/tree/main/zip
    # """
    local -A app dict
    local -a build_deps deps
    build_deps=('make')
    # Currently hitting build issues when using Clang on macOS.
    koopa_is_macos && build_deps+=('gcc')
    deps=('bzip2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    local -A app
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['version']}" in
        '3.0')
            # 2023-02-19.
            dict['patch_version']='13'
            ;;
        *)
            koopa_stop 'Unsupported version.'
            ;;
    esac
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['version']}"
    )"
    dict['url']="https://downloads.sourceforge.net/project/infozip/\
Zip%20${dict['maj_ver']}.x%20%28latest%29/${dict['version']}/\
zip${dict['version2']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_apply_debian_patch_set \
        --name='zip' \
        --patch-version="${dict['patch_version']}" \
        --target='src' \
        --version="${dict['version']}"
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" -f 'unix/Makefile' \
        'CC=gcc' \
        'generic'
    "${app['make']}" -f 'unix/Makefile' \
        "prefix=${dict['prefix']}" \
        "BINDIR=${dict['prefix']}/bin" \
        "MANDIR=${dict['prefix']}/share/man/man1" \
        install
    return 0
}

