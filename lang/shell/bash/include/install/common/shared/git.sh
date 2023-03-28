#!/usr/bin/env bash

# FIXME Need to address missing manual entries.
# e.g. git help fetch
# No manual entry

# NOTE Consider requiring expat here.

# FIXME Build git subtree.
# FIXME Set osxkeychain as default helper on macOS.

main() {
    # """
    # Install Git.
    # @note Updated 2023-03-28.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # Git source code releases on GitHub:
    # > file="v${version}.tar.gz"
    # > url="https://github.com/git/${name}/archive/${file}"
    #
    # @seealso
    # - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/git.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'less' \
        'make' \
        'perl' \
        'python3.11' \
        'vim'
    koopa_activate_app \
        'expat' \
        'zlib' \
        'gettext' \
        'openssl3' \
        'curl' \
        'pcre2' \
        'libiconv'
    declare -A app=(
        ['bash']="$(koopa_locate_bash --realpath)"
        ['less']="$(koopa_locate_less --realpath)"
        ['make']="$(koopa_locate_make)"
        ['perl']="$(koopa_locate_perl --realpath)"
        ['python']="$(koopa_locate_python311 --realpath)"
        ['vim']="$(koopa_locate_vim --realpath)"
    )
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['less']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['curl']="$(koopa_app_prefix 'curl')"
        ['expat']="$(koopa_app_prefix 'expat')"
        ['jobs']="$(koopa_cpu_count)"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['mirror_url']='https://mirrors.edge.kernel.org/pub/software/scm'
        ['name']='git'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    koopa_assert_is_dir \
        "${dict['curl']}" \
        "${dict['expat']}" \
        "${dict['libiconv']}" \
        "${dict['openssl']}" \
        "${dict['pcre2']}" \
        "${dict['zlib']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="${dict['mirror_url']}/${dict['name']}/${dict['file']}"
    dict['htmldocs_file']="${dict['name']}-htmldocs-${dict['version']}.tar.xz"
    dict['htmldocs_url']="${dict['mirror_url']}/\
${dict['name']}/${dict['htmldocs_file']}"
    dict['manpages_file']="${dict['name']}-manpages-${dict['version']}.tar.xz"
    dict['manpages_url']="${dict['mirror_url']}/\
${dict['name']}/${dict['manpages_file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_download "${dict['htmldocs_url']}" "${dict['htmldocs_file']}"
    koopa_download "${dict['manpages_url']}" "${dict['manpages_file']}"
    koopa_stop 'FIXME REWORK THIS.'
    koopa_extract "${dict['file']}"
    koopa_extract \
        "${dict['htmldocs_file']}" \
        "${dict['prefix']}/share/doc/git-doc"
    koopa_extract \
        "${dict['manpages_file']}" \
        "${dict['prefix']}/share/man"
    koopa_cd "${dict['name']}-${dict['version']}"
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
