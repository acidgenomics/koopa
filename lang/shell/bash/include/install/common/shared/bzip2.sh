#!/usr/bin/env bash

main() {
    # """
    # Install bzip2.
    # @note Updated 2022-08-27.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://gitlab.com/federicomenaquintero/bzip2
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb
    # - https://github.com/macports/macports-ports/blob/master/archivers/
    #     bzip2/Portfile
    # - https://stackoverflow.com/questions/67179779/
    # - https://opensource.apple.com/source/bzip2/bzip2-16.5/bzip2/
    #     Makefile.auto.html
    # - https://gist.githubusercontent.com/obihill/
    #     3278c17bcee41c0c8b59a41ada8c0d35/raw/
    #     3bf890e2ad40d0af358e153395c228326f0b44d5/Makefile-libbz2_dylib
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='bzip2'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://sourceware.org/pub/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['make']}" install "PREFIX=${dict['prefix']}"
    return 0
}
