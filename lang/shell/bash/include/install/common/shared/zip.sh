#!/usr/bin/env bash

main() {
    # """
    # Install zip.
    # @note Updated 2023-04-08.
    #
    # Upstream is unmaintained so we use the Debian patchset:
    # https://packages.debian.org/sid/zip
    #
    # @seealso
    # - http://infozip.sourceforge.net/Zip.html
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
    [[ -x "${app['make']}" ]] || exit 1
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['bzip2']}"
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
    apply_debian_patch_set
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

# FIXME Make this a shared function, similar to apply_ubuntu_patch_set.
# FIXME Rework this to support a patch version variable.
# FIXME Consider using this for unzip as well.

apply_debian_patch_set() {
    # """
    # Apply Debian patch set.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    local -a patch_series
    local file
    app['patch']="$(koopa_locate_patch)"
    [[ -x "${app['patch']}" ]] || exit 1
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
    # FIXME Get the first letter of the name.
    dict['url']="https://deb.debian.org/debian/pool/main/z/${dict['name']}/\
${dict['name']}_${dict['version']}-${dict['patch_ver']}.debian.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")"
    koopa_assert_is_dir 'debian/patches'
    koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        koopa_cd 'src'
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
