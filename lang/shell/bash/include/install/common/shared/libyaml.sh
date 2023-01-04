#!/usr/bin/env bash

# FIXME Seeing this error when running autoconf:
#
# autoreconf: running: /opt/koopa/app/autoconf/2.71/bin/autoconf --force
# configure.ac:62: warning: The macro `AC_HEADER_STDC' is obsolete.
# configure.ac:62: You should run autoupdate.
# ./lib/autoconf/headers.m4:704: AC_HEADER_STDC is expanded from...
# configure.ac:62: the top level
# configure.ac:56: error: possibly undefined macro: AC_PROG_LIBTOOL
#       If this token and others are legitimate, please use m4_pattern_allow.
#       See the Autoconf documentation.
# autoreconf: error: /opt/koopa/app/autoconf/2.71/bin/autoconf failed with exit status: 1
#
# https://stackoverflow.com/questions/53636130/possibly-undefined-macro-ac-prog-libtool

main() {
    # """
    # Install libyaml.
    # @note Updated 2023-01-04.
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
        'libtool'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libyaml'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    # https://superuser.com/questions/565988/autoconf-libtool-and-an-undefined-ac-prog-libtool
    autoupdate --verbose # FIXME
    ACLOCAL_PATH='/opt/koopa/app/libtool/2.4.7/share/aclocal' \
        autoreconf -fvi # FIXME
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
