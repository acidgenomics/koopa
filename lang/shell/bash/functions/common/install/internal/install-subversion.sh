#!/usr/bin/env bash

koopa:::install_subversion() { # {{{1
    # """
    # Install Subversion.
    # @note Updated 2022-01-06.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # """
    local app conf_args dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='subversion'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=("--prefix=${dict[prefix]}")
    if koopa::is_linux
    then
        if koopa::is_fedora
        then
            koopa::ln --sudo '/usr/bin/apr-1-config' '/usr/bin/apr-config'
            koopa::ln --sudo '/usr/bin/apu-1-config' '/usr/bin/apu-config'
            koopa::add_to_pkg_config_path_start '/usr/lib64/pkgconfig'
        fi
        koopa::assert_is_installed 'apr-config' 'apu-config' 'sqlite3'
        conf_args+=(
            '--with-lz4=internal'
            '--with-utf8proc=internal'
        )
    elif koopa::is_macos
    then
        dict[brew_prefix]="$(koopa::homebrew_prefix)"
        dict[brew_apr]="${dict[brew_prefix]}/opt/apr"
        dict[brew_apr_util]="${dict[brew_prefix]}/opt/apr-util"
        koopa::assert_is_dir \
            "${dict[brew_apr]}" \
            "${dict[brew_apr_util]}" \
            "${dict[brew_prefix]}"
        conf_args+=(
            "--with-apr=${dict[brew_apr]}"
            "--with-apr-util=${dict[brew_apr_util]}"
        )
    fi
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://mirrors.ocf.berkeley.edu/apache/\
${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
