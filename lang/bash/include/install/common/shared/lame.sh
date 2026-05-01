#!/usr/bin/env bash

main() {
    # """
    # Install LAME.
    # @note Updated 2025-01-03.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lame.rb
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-static'
        '--enable-nasm'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://koopa.acidgenomics.com/src/lame/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_find_and_replace_in_file \
        --multiline \
        --pattern='lame_init_old\n' \
        --regex \
        --replacement='' \
        'include/libmp3lame.sym'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
