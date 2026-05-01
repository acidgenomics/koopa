#!/usr/bin/env bash

main() {
    # """
    # Install SQLite.
    # @note Updated 2024-12-30.
    #
    # Year mappings for installers are here:
    # https://www.sqlite.org/chronology.html
    #
    # @seealso
    # - https://github.com/conda-forge/sqlite-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/sqlite.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/server/sqlite.html
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'zlib' 'readline'
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['version']}" in
        '3.47.'*)
            dict['year']='2024'
            ;;
        '3.44.'* | \
        '3.43.'* | \
        '3.42.'* | \
        '3.41.'*)
            dict['year']='2023'
            ;;
        '3.40.'* | \
        '3.39.'* | \
        '3.38.'* | \
        '3.37.2')
            dict['year']='2022'
            ;;
        '3.37.'* | \
        '3.36.'* | \
        '3.35.'* | \
        '3.34.1')
            dict['year']='2021'
            ;;
        '3.34.'* | \
        '3.33.'* | \
        '3.32.'*)
            dict['year']='2020'
            ;;
        *)
            _koopa_stop "Unsupported version: '${dict['version']}'."
            ;;
    esac
    # e.g. '3.32.3' to '3320300'.
    dict['file_version']="$( \
        _koopa_print "${dict['version']}" \
        | "${app['sed']}" -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
    )"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-editline'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-readline'
        '--enable-shared=yes'
        '--enable-threadsafe'
        "--prefix=${dict['prefix']}"
    )
    _koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    dict['url']="https://www.sqlite.org/${dict['year']}/\
sqlite-autoconf-${dict['file_version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
