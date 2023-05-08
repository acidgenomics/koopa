#!/usr/bin/env bash

# FIXME Need to fix iconv library paths
# https://github.com/GNOME/libxml2/commit/3463063001f36c16e5f6ce9ad33cd12a376fc874

main() {
    # """
    # Install libxml2.
    # @note Updated 2023-05-08.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('make' 'pkg-config')
    deps=(
        'zlib'
        'icu4c'
        'readline'
        'libiconv'
        'xz'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--enable-static=no'
        "--prefix=${dict['prefix']}"
        '--with-ftp'
        '--with-history'
        "--with-iconv=${dict['libiconv']}"
        '--with-icu'
        '--with-legacy'
        "--with-lzma=${dict['xz']}"
        "--with-readline=${dict['readline']}"
        "--with-zlib=${dict['zlib']}"
        '--without-python'
    )
    case "${dict['version']}" in
        '2.11.2')
            # FIXME This is expecting autoconf 2.63.
            # FIXME This is expecting automake 1.16.3.
            local -A app
            # FIXME Need to rework this.
            # > app['autoreconf']='/opt/koopa/app/autoconf2.65/2.65/bin/autoreconf'
            app['libtoolize']="$(koopa_locate_libtoolize)"
            koopa_assert_is_executable "${app[@]}"
            koopa_activate_app --build-only \
                'autoconf' \
                'automake' \
                'libtool'
            dict['commit']='3463063001f36c16e5f6ce9ad33cd12a376fc874'
            dict['url']='https://github.com/GNOME/libxml2'
            koopa_git_clone \
                --commit="${dict['commit']}" \
                --prefix='src' \
                --url="${dict['url']}"
            koopa_cd 'src'
            # > "${app['libtoolize']}"
            # > "${app['autoreconf']}" --force --install --verbose
            # > libtoolize --force
            libtoolize
            aclocal
            autoheader
            automake --force-missing --add-missing
            autoconf
            ;;
        *)
            dict['url']="https://download.gnome.org/sources/libxml2/\
${dict['maj_min_ver']}/libxml2-${dict['version']}.tar.xz"
            koopa_download "${dict['url']}"
            koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
            koopa_cd 'src'
            ;;
    esac
    koopa_make_build "${conf_args[@]}"
    return 0
}
