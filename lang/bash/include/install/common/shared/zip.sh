#!/usr/bin/env bash

main() {
    # """
    # Install zip.
    # @note Updated 2023-10-16.
    #
    # Upstream is unmaintained so we use the Debian patchset:
    # https://packages.debian.org/sid/zip
    #
    # @seealso
    # - http://infozip.sourceforge.net/Zip.html
    # - http://ftp.debian.org/debian/pool/main/z/zip/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zip.rb
    # - https://git.alpinelinux.org/aports/tree/main/zip
    # - https://fossies.org/linux/zip/bzip2/install.txt
    # """
    local -A app dict
    local -a make_args make_install_args
    koopa_activate_app --build-only 'make'
    app['cc']="$(koopa_locate_cc --only-system)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
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
    if koopa_is_macos
    then
        # Fix compile with clang 15. Otherwise configure thinks 'memset()' and
        # others are missing.
        # See also:
        # - https://github.com/Homebrew/formula-patches/blob/master/
        #     zip/xcode15.diff
        dict['patch_prefix']="$(koopa_patch_prefix)"
        dict['patch_file']="${dict['patch_prefix']}/macos/zip/xcode15.diff"
        koopa_assert_is_file "${dict['patch_file']}"
        "${app['patch']}" \
            --input="${dict['patch_file']}" \
            --strip=1 \
            --verbose
    fi
    make_args+=(
        '-f' 'unix/Makefile'
        "CC=${app['cc']}"
        'generic'
    )
    make_install_args+=(
        '-f' 'unix/Makefile'
        "prefix=${dict['prefix']}"
        "BINDIR=${dict['prefix']}/bin"
        "MANDIR=${dict['prefix']}/share/man/man1"
    )
    koopa_print_env
    "${app['make']}" "${make_args[@]}"
    "${app['make']}" "${make_install_args[@]}" install
    koopa_cd '..'
    koopa_mkdir 'test'
    koopa_cd 'test'
    app['zip']="${dict['prefix']}/bin/zip"
    koopa_assert_is_executable "${app['zip']}"
    "${app['zip']}" -v
    return 0
}

