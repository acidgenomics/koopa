#!/usr/bin/env bash

main() {
    # """
    # Install Bash completion.
    # @note Updated 2025-01-02.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/bash-completion@2
    # - https://github.com/scop/bash-completion
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    dict['url']="https://github.com/scop/bash-completion/releases/download/\
${dict['version']}/bash-completion-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
