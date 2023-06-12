#!/usr/bin/env bash

main() {
    # """
    # Install Git.
    # @note Updated 2023-06-12.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # @seealso
    # - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/git.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'autoconf' 'make'
    koopa_activate_app \
        'expat' \
        'zlib' \
        'gettext' \
        'openssl3' \
        'curl' \
        'pcre2' \
        'libiconv'
    app['bash']="$(koopa_locate_bash)"
    app['less']="$(koopa_locate_less)"
    app['make']="$(koopa_locate_make)"
    app['perl']="$(koopa_locate_perl)"
    app['python']="$(koopa_locate_python311)"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['expat']="$(koopa_app_prefix 'expat')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url_base']='https://mirrors.edge.kernel.org/pub/software/scm/git'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
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
    dict['url']="${dict['url_base']}/git-${dict['version']}.tar.gz"
    dict['htmldocs_url']="${dict['url_base']}/\
git-htmldocs-${dict['version']}.tar.xz"
    dict['manpages_url']="${dict['url_base']}/\
git-manpages-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_download "${dict['htmldocs_url']}"
    koopa_download "${dict['manpages_url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        'src'
    koopa_extract \
        "$(koopa_basename "${dict['htmldocs_url']}")" \
        "${dict['prefix']}/share/doc/git-doc"
    koopa_extract \
        "$(koopa_basename "${dict['manpages_url']}")" \
        "${dict['prefix']}/share/man"
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    "${app['make']}" configure
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    (
        koopa_cd 'contrib/subtree'
        "${app['make']}" --jobs="${dict['jobs']}"
        koopa_cp \
            --target-directory="${dict['prefix']}/bin" \
            'git-subtree'
    )
    if koopa_is_macos
    then
        (
            koopa_cd 'contrib/credential/osxkeychain'
            "${app['make']}" --jobs="${dict['jobs']}"
            koopa_cp \
                --target-directory="${dict['prefix']}/bin" \
                'git-credential-osxkeychain'
        )
        read -r -d '' "dict[gitconfig_string]" << END || true
[credential]
    helper = osxkeychain
END
        dict['gitconfig_file']="${dict['prefix']}/etc/gitconfig"
        koopa_append_string \
            --file="${dict['gitconfig_file']}" \
            --string="${dict['gitconfig_string']}"
    fi
    return 0
}
