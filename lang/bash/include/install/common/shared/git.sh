#!/usr/bin/env bash

main() {
    # """
    # Install Git.
    # @note Updated 2026-04-24.
    #
    # @seealso
    # - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
    # - https://github.com/conda-forge/git-feedstock
    # - https://formulae.brew.sh/formula/git
    # - https://stackoverflow.com/questions/27798181
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps+=('autoconf' 'make')
    deps+=(
        'expat'
        'zlib'
        'gettext'
        'openssl'
        'zstd' # curl
        'libssh2' # curl
        'curl'
        'pcre2'
        'libiconv'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    app['bash']="$(_koopa_locate_bash)"
    app['less']="$(_koopa_locate_less)"
    app['make']="$(_koopa_locate_make)"
    app['perl']="$(_koopa_locate_perl)"
    app['python']="$(_koopa_locate_python)"
    app['vim']="$(_koopa_locate_vim)"
    _koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(_koopa_app_prefix 'curl')"
    dict['expat']="$(_koopa_app_prefix 'expat')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['libiconv']="$(_koopa_app_prefix 'libiconv')"
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['pcre2']="$(_koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url_base']='https://mirrors.edge.kernel.org/pub/software/scm/git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--with-curl=${dict['curl']}"
        "--with-editor=${app['vim']}"
        "--with-expat=${dict['expat']}"
        "--with-iconv=${dict['libiconv']}"
        "--with-libpcre2=${dict['pcre2']}"
        "--with-openssl=${dict['openssl']}"
        "--with-pager=${app['less']}"
        "--with-perl=${app['perl']}"
        "--with-python=${app['python']}"
        "--with-shell=${app['bash']}"
        "--with-zlib=${dict['zlib']}"
        '--without-tcltk'
    )
    dict['url']="${dict['url_base']}/git-${dict['version']}.tar.xz"
    dict['htmldocs_url']="${dict['url_base']}/\
git-htmldocs-${dict['version']}.tar.xz"
    dict['manpages_url']="${dict['url_base']}/\
git-manpages-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_download "${dict['htmldocs_url']}"
    _koopa_download "${dict['manpages_url']}"
    _koopa_extract \
        "$(_koopa_basename "${dict['url']}")" \
        'src'
    _koopa_extract \
        "$(_koopa_basename "${dict['htmldocs_url']}")" \
        "${dict['prefix']}/share/doc/git-doc"
    _koopa_extract \
        "$(_koopa_basename "${dict['manpages_url']}")" \
        "${dict['prefix']}/share/man"
    _koopa_cd 'src'
    _koopa_print_env
    _koopa_dl 'configure args' "${conf_args[*]}"
    "${app['make']}" configure
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        NO_IMAP_SEND='YesPlease' \
        NO_INSTALL_HARDLINKS='YesPlease' \
        VERBOSE=1
    "${app['make']}" \
        NO_IMAP_SEND='YesPlease' \
        NO_INSTALL_HARDLINKS='YesPlease' \
        install
    _koopa_alert 'Installing subtree.'
    (
        _koopa_cd 'contrib/subtree'
        "${app['make']}" --jobs="${dict['jobs']}"
        _koopa_cp \
            --target-directory="${dict['prefix']}/bin" \
            'git-subtree'
    )
# >     if _koopa_is_macos
# >     then
# >         _koopa_alert 'Installing osxkeychain.'
# >         (
# >             _koopa_cd 'contrib/credential/osxkeychain'
# >             "${app['make']}" --jobs="${dict['jobs']}"
# >             _koopa_cp \
# >                 --target-directory="${dict['prefix']}/bin" \
# >                 'git-credential-osxkeychain'
# >         )
# >         read -r -d '' "dict[gitconfig_string]" << END || true
# > [credential]
# >     helper = osxkeychain
# > END
# >         dict['gitconfig_file']="${dict['prefix']}/etc/gitconfig"
# >         _koopa_append_string \
# >             --file="${dict['gitconfig_file']}" \
# >             --string="${dict['gitconfig_string']}"
# >     fi
    _koopa_alert 'Installing completions.'
    _koopa_cp \
        --target-directory="${dict['prefix']}/share" \
        'contrib/completion'
    return 0
}
