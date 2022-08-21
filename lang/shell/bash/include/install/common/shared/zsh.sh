#!/usr/bin/env bash

main() {
    # """
    # Install Zsh.
    # @note Updated 2022-07-28.
    #
    # Need to configure Zsh to support system-wide config files in '/etc/zsh'.
    # Note that RHEL 7 locates these to '/etc' by default instead.
    #
    # We're linking these instead, at '/usr/local/etc/zsh'.
    # There are some system config files for Zsh in Debian that don't play nice
    # with autocomplete otherwise.
    #
    # Fix required for Ubuntu Docker image:
    # configure: error: no controlling tty
    # Try running configure with '--with-tcsetpgrp' or '--without-tcsetpgrp'.
    #
    # Mirrors:
    # - url="ftp://ftp.fu-berlin.de/pub/unix/shells/${name}/${file}"
    # - url="https://www.zsh.org/pub/${file}" (slow)
    # - url="https://downloads.sourceforge.net/project/\
    #       ${name}/${name}/${version}/${file}" (redirects, curl issues)
    #
    # See also:
    # - https://github.com/Homebrew/legacy-homebrew/issues/25719
    # - https://github.com/TACC/Lmod/issues/434
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'ncurses' \
        'pcre' \
        'texinfo'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [jobs]="$(koopa_cpu_count)"
        [name]='zsh'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict['name']}-${dict['version']}.tar.xz"
    dict[url]="https://downloads.sourceforge.net/project/\
${dict['name']}/${dict['name']}/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-cap'
        '--enable-etcdir=/etc'
        '--enable-maildir-support'
        '--enable-multibyte'
        '--enable-pcre'
        '--enable-unicode9'
        '--enable-zsh-secure-free'
        '--with-tcsetpgrp'
    )
    # Work around configure issues with Xcode 12.
    # https://www.zsh.org/mla/workers/2020/index.html
    # https://github.com/Homebrew/homebrew-core/issues/64921
    if koopa_is_macos
    then
        CFLAGS="-Wno-implicit-function-declaration ${CFLAGS:-}"
        export CFLAGS
    fi
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    "${app['make']}" install.info
    if koopa_is_shared_install
    then
        koopa_enable_shell_for_all_users "${dict['bin_prefix']}/${dict['name']}"
    fi
    return 0
}
