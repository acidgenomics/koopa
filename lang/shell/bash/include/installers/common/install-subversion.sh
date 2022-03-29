#!/usr/bin/env bash

install_subversion() { # {{{1
    # """
    # Install Subversion.
    # @note Updated 2022-03-29.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # - Need to use serf to support HTTPS URLs.
    #   https://serverfault.com/questions/522646/
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew 2>/dev/null || true)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='subversion'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
    )
    if koopa_is_installed "${app[brew]}"
    then
        dict[brew_prefix]="$(koopa_homebrew_prefix)"
        dict[brew_apr]="${dict[brew_prefix]}/opt/apr"
        dict[brew_apr_util]="${dict[brew_prefix]}/opt/apr-util"
        koopa_assert_is_dir \
            "${dict[brew_apr]}" \
            "${dict[brew_apr_util]}" \
            "${dict[brew_prefix]}"
        conf_args+=(
            "--with-apr=${dict[brew_apr]}"
            "--with-apr-util=${dict[brew_apr_util]}"
        )
    elif koopa_is_linux
    then
        if koopa_is_fedora
        then
            koopa_ln --sudo '/usr/bin/apr-1-config' '/usr/bin/apr-config'
            koopa_ln --sudo '/usr/bin/apu-1-config' '/usr/bin/apu-config'
            koopa_add_to_pkg_config_path_start '/usr/lib64/pkgconfig'
        fi
        koopa_assert_is_installed 'apr-config' 'apu-config' 'sqlite3'
        conf_args+=(
            '--with-lz4=internal'
            '--with-serf' # Required for HTTPS URLs.
            '--with-utf8proc=internal'
        )
    fi
    koopa_activate_opt_prefix \
        'perl' \
        'python' \
        'ruby'
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://mirrors.ocf.berkeley.edu/apache/\
${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
