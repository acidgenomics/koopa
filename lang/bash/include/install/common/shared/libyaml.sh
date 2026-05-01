#!/usr/bin/env bash

main() {
    # """
    # Install libyaml.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libyaml.rb
    # - https://www.gnu.org/software/automake/manual/html_node/
    #     Macro-Search-Path.html
    # - https://superuser.com/questions/565988/
    # """
    local -A app dict
    _koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'm4' \
        'pkg-config'
    app['autoreconf']="$(_koopa_locate_autoreconf)"
    app['autoupdate']="$(_koopa_locate_autoupdate)"
    dict['libtool']="$(_koopa_app_prefix 'libtool')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/yaml/libyaml/archive/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    "${app['autoupdate']}" --verbose
    ACLOCAL_PATH="${dict['libtool']}/share/aclocal" \
        "${app['autoreconf']}" --force --install --verbose
    _koopa_make_build "${conf_args[@]}"
    return 0
}
