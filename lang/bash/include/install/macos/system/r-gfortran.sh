#!/usr/bin/env bash

main() {
    # """
    # Install GNU Fortran (for R).
    # @note Updated 2023-10-09.
    #
    # @seealso
    # - https://mac.r-project.org/tools/
    # """
    local -A app dict
    app['installer']="$(_koopa_macos_locate_installer)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://mac.r-project.org/tools/gfortran-${dict['version']}-\
universal.pkg"
    _koopa_download "${dict['url']}"
    _koopa_sudo \
        "${app['installer']}" \
        -pkg "$(_koopa_basename "${dict['url']}")" \
        -target '/'
    _koopa_assert_is_dir '/opt/gfortran'
    return 0
}
