#!/usr/bin/env bash

# FIXME Disable more stuff here...Perl, Ruby, etc...

main() {
    # """
    # Install swig.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/conda-forge/swig-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/swig.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'pcre2'
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
        "--with-pcre2-prefix=${dict['pcre2']}"
        '--without-alllang'
    )
    dict['url']="https://downloads.sourceforge.net/project/swig/swig/\
swig-${dict['version']}/swig-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
