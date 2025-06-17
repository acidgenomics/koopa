#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install jq.
    # @note Updated 2023-04-10.
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
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'pkg-config'
    koopa_activate_app \
        'm4' \
        'gettext' \
        'oniguruma'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['libtoolize']="$(koopa_locate_libtoolize)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url_stem']="https://github.com/stedolan/jq"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-docs'
        '--disable-maintainer-mode'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    case "${dict['version']}" in
        '1.6')
            # The current 1.6 release installer fails to compile on macOS.
            dict['commit']='f9afa950e26f5d548d955f92e83e6b8e10cc8438'
            dict['url']="${dict['url_stem']}/archive/${dict['commit']}.tar.gz"
            ;;
        *)
            dict['url']="${dict['url_stem']}/releases/download/\
jq-${dict['version']}/jq-${dict['version']}.tar.gz"
            ;;
    esac
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['libtoolize']}"
    "${app['autoreconf']}" --force --install --verbose
    koopa_make_build "${conf_args[@]}"
    return 0
}

main() {
    install_from_conda
    return 0
}
