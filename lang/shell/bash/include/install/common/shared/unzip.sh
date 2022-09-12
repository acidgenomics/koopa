#!/usr/bin/env bash

main() {
    # """
    # Install unzip.
    # @note Updated 2022-09-01.
    #
    # Upstream is unmaintained so we use the Ubuntu patchset:
    # https://packages.ubuntu.com/kinetic/unzip
    #
    # @seealso
    # - http://infozip.sourceforge.net/UnZip.html
    # - https://sourceforge.net/projects/infozip/files/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/unzip.rb
    # - https://git.alpinelinux.org/aports/tree/main/unzip
    # """
    local app dict loc_macros make_args
    koopa_activate_opt_prefix 'bzip2'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['name']='unzip'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['bzip2']}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['version']}"
    )"
    # > dict['file']="${dict['name']}${dict['version2']}.tgz"
    # This FTP server doesn't work currently.
    # > dict['url']="ftp://ftp.info-zip.org/pub/infozip/src/${dict['file']}"
    # This is a copy from 'ftp.info-zip.org'.
    # > dict['url']="https://dev.alpinelinux.org/archive/unzip/${dict['file']}"
    # Use the canonical SourceForge URL instead.
    dict['file']="${dict['name']}${dict['version2']}.tar.gz"
    dict['url']="https://downloads.sourceforge.net/project/infozip/\
UnZip%20${dict['maj_ver']}.x%20%28latest%29/UnZip%20${dict['version']}/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    apply_ubuntu_patch_set
    koopa_cd "${dict['name']}${dict['version2']}"
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

apply_ubuntu_patch_set() {
    # """
    # Apply Ubuntu patch set (to 6.0 release).
    # @note Updated 2022-09-01.
    # """
    local app dict file
    declare -A app=(
        ['patch']="$(koopa_locate_patch)"
    )
    [[ -x "${app['patch']}" ]] || return 1
    declare -A dict=(
        ['name']='unzip'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    case "${dict['version']}" in
        '6.0')
            dict['patch_ver']='27'
            ;;
        *)
            return 0
            ;;
    esac
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['version']}"
    )"
    dict['file']="${dict['name']}_${dict['version']}-\
${dict['patch_ver']}ubuntu1.debian.tar.xz"
    dict['url']="http://archive.ubuntu.com/ubuntu/pool/main/u/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_assert_is_dir 'debian/patches'
    (
        koopa_cd "${dict['name']}${dict['version2']}"
        for file in '../debian/patches/'*'.patch'
        do
            "${app['patch']}" \
                --input="$file" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}
