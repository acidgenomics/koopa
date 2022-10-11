#!/usr/bin/env bash

main() {
    # """
    # Install jq.
    # @note Updated 2022-07-12.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/jq.rb
    # - https://trac.macports.org/ticket/61354
    # - https://github.com/macports/macports-ports/pull/8870
    # - https://github.com/macports/macports-ports/blob/master/sysutils/
    #     jq/Portfile
    # - https://github.com/stedolan/jq/pull/2196
    # - https://stackoverflow.com/questions/18978252/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app \
        'm4' \
        'autoconf' \
        'automake' \
        'gettext' \
        'libtool' \
        'oniguruma'
    declare -A app=(
        ['autoreconf']="$(koopa_locate_autoreconf)"
        ['libtoolize']="$(koopa_locate_libtoolize)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['autoreconf']}" ]] || return 1
    [[ -x "${app['libtoolize']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='jq'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['url_stem']="https://github.com/stedolan/${dict['name']}"
    case "${dict['version']}" in
        '1.6')
            # The current 1.6 release installer fails to compile on macOS.
            dict['commit']='f9afa950e26f5d548d955f92e83e6b8e10cc8438'
            dict['file']="${dict['commit']}.tar.gz"
            dict['url']="${dict['url_stem']}/archive/${dict['file']}"
            dict['dirname']="${dict['name']}-${dict['commit']}"
            ;;
        *)
            dict['file']="${dict['name']}-${dict['version']}.tar.gz"
        dict['url']="${dict['url_stem']}/releases/\
download/${dict['name']}-${dict['version']}/${dict['file']}"
            dict['dirname']="${dict['name']}-${dict['version']}"
            ;;
    esac
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['dirname']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-docs'
        '--disable-maintainer-mode'
        '--disable-silent-rules'
    )
    "${app['libtoolize']}"
    "${app['autoreconf']}" -iv
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
