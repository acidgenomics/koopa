#!/usr/bin/env bash

main() {
    # """
    # Install zip.
    # @note Updated 2022-10-12.
    #
    # Upstream is unmaintained so we use the Debian patchset:
    # https://packages.debian.org/sid/zip
    #
    # @seealso
    # - http://infozip.sourceforge.net/Zip.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zip.rb
    # - https://git.alpinelinux.org/aports/tree/main/zip
    # """
    local build_deps app deps dict
    build_deps=('make')
    # Currently hitting build issues when using Clang on macOS.
    koopa_is_macos && build_deps+=('gcc')
    deps=('bzip2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['name']='zip'
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
    dict['file']="${dict['name']}${dict['version2']}.tar.gz"
    dict['url']="https://downloads.sourceforge.net/project/infozip/\
Zip%20${dict['maj_ver']}.x%20%28latest%29/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    apply_debian_patch_set
    koopa_cd "${dict['name']}${dict['version2']}"
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

apply_debian_patch_set() {
    # """
    # Apply Debian patch set (to 3.0 release).
    # @note Updated 2022-10-12.
    # """
    local app dict file
    local -A app
    app['patch']="$(koopa_locate_patch)"
    [[ -x "${app['patch']}" ]] || exit 1
    local -A dict=(
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    case "${dict['version']}" in
        '3.0')
            dict['patch_ver']='11'
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
${dict['patch_ver']}.debian.tar.xz"
    # FIXME Get the first letter of the name.
    dict['url']="https://deb.debian.org/debian/pool/main/z/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_assert_is_dir 'debian/patches'
    local patch_series
    readarray -t patch_series < 'debian/patches/series'
    (
        koopa_cd "${dict['name']}${dict['version2']}"
        local patch
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(koopa_realpath .."/debian/patches/${patch}")"
            koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}
