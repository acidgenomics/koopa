#!/usr/bin/env bash

main() {
    # """
    # Install libyaml.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libyaml.rb
    # - https://www.gnu.org/software/automake/manual/html_node/
    #     Macro-Search-Path.html
    # - https://superuser.com/questions/565988/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'm4' \
        'make' \
        'pkg-config'
    declare -A app=(
        ['autoreconf']="$(koopa_locate_autoreconf)"
        ['autoupdate']="$(koopa_locate_autoupdate)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['autoreconf']}" ]] || exit 1
    [[ -x "${app['autoupdate']}" ]] || exit 1
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['libtool']="$(koopa_app_prefix 'libtool')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libyaml'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['libtool']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/yaml/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    "${app['autoupdate']}" --verbose
    ACLOCAL_PATH="${dict['libtool']}/share/aclocal" \
        "${app['autoreconf']}" -fvi
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
