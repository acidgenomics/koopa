#!/usr/bin/env bash

main() {
    # """
    # Install SQLite.
    # @note Updated 2023-03-07.
    #
    # Use autoconf instead of amalgamation.
    #
    # Year mappings for installers are here:
    # https://www.sqlite.org/chronology.html
    #
    # The '--enable-static' flag is required, otherwise you'll hit a version
    # mismatch error:
    # > sqlite3 --version
    # ## SQLite header and source version mismatch
    # https://askubuntu.com/questions/443379
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/server/sqlite.html
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'zlib' 'readline'
    local -A app=(
        ['make']="$(koopa_locate_make)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['make']}" ]] || exit 1
    [[ -x "${app['sed']}" ]] || exit 1
    local -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='sqlite'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    case "${dict['version']}" in
        '3.41.'*)
            dict['year']='2023'
            ;;
        '3.40.'* | '3.39.'* | '3.38.'* | \
        '3.37.2')
            dict['year']='2022'
            ;;
        '3.37.'* | '3.36.'* | '3.35.'* | \
        '3.34.1')
            dict['year']='2021'
            ;;
        '3.34.'* | '3.33.'* | '3.32.'*)
            dict['year']='2020'
            ;;
        *)
            koopa_stop "Unsupported version: '${dict['version']}'."
            ;;
    esac
    # e.g. '3.32.3' to '3320300'.
    dict['file_version']="$( \
        koopa_print "${dict['version']}" \
        | "${app['sed']}" -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
    )"
    dict['file']="${dict['name']}-autoconf-${dict['file_version']}.tar.gz"
    dict['url']="https://www.sqlite.org/${dict['year']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-autoconf-${dict['file_version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        # > '--disable-dynamic-extensions'
        # > '--disable-shared'
        '--enable-static'
        '--enable-shared'
    )
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
