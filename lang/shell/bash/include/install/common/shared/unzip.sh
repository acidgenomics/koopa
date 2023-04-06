#!/usr/bin/env bash

main() {
    # """
    # Install unzip.
    # @note Updated 2023-04-06.
    #
    # Upstream is unmaintained so we use the Ubuntu patchset:
    # https://packages.ubuntu.com/kinetic/unzip
    #
    # @seealso
    # - http://infozip.sourceforge.net/UnZip.html
    # - https://sourceforge.net/projects/infozip/files/
    # - http://ftp.debian.org/debian/pool/main/u/unzip/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/unzip.rb
    # - https://git.alpinelinux.org/aports/tree/main/unzip
    # """
    local -A app dict
    local -a loc_macros make_args
    koopa_activate_app --build-only 'make'
    koopa_activate_app 'bzip2'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['version']}" in
        '6.0')
            # 2023-02-19.
            dict['patch_version']='28'
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
UnZip%20${dict['maj_ver']}.x%20%28latest%29/UnZip%20${dict['version']}/\
unzip${dict['version2']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_apply_debian_patch_set \
        --name="${dict['name']}" \
        --patch-version="${dict['patch_version']}" \
        --target='src' \
        --version="${dict['version']}"
    koopa_cd 'src'
    # These macros also follow Ubuntu, and are required to:
    # - Correctly handle large archives (> 4GB).
    # - Extract & print archive contents with non-latin characters.
    loc_macros=(
        '-DLARGE_FILE_SUPPORT'
        '-DNO_WORKING_ISPRINT'
        '-DUNICODE_SUPPORT'
        '-DUNICODE_WCHAR'
        '-DUTF8_MAYBE_NATIVE'
    )
    make_args=(
        "prefix=${dict['prefix']}"
        'CC=gcc'
        "LOC=${loc_macros[*]}"
        'D_USE_BZ2=-DUSE_BZIP2'
        "L_BZ2=-L${dict['bzip2']}/lib -lbz2"
    )
    if koopa_is_macos
    then
        make_args+=(
            'LFLAGS1=-liconv'
            'macosx'
        )
    else
        make_args+=('generic')
    fi
    koopa_print_env
    "${app['make']}" -f 'unix/Makefile' "${make_args[@]}"
    "${app['make']}" -f 'unix/Makefile' check
    "${app['make']}" -f 'unix/Makefile' \
        "prefix=${dict['prefix']}" \
        "MANDIR=${dict['prefix']}/share/man/man1" \
        install
    return 0
}
