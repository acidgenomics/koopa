#!/usr/bin/env bash

main() {
    # """
    # Install Zsh.
    # @note Updated 2024-06-12.
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
    #       ${name}/${name}/${version}/${file}" (redirects)
    #
    # @seealso
    # - https://github.com/conda-forge/zsh-feedstock
    # - https://formulae.brew.sh/formula/zsh
    # - https://github.com/Homebrew/legacy-homebrew/issues/25719
    # - https://github.com/TACC/Lmod/issues/434
    # """
    local -A dict
    local -a conf_args deps
    deps+=('ncurses' 'pcre' 'texinfo')
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        # Configuration common with conda-forge:
        '--enable-pcre'
        "--prefix=${dict['prefix']}"
        '--with-tcsetpgrp'
        # Additional configuration defined in Homebrew:
        # > '--enable-cap'
        # > '--enable-etcdir=/etc'
        # > '--enable-maildir-support'
        # > '--enable-multibyte'
        # > '--enable-unicode9'
        # > '--enable-zsh-secure-free'
    )
    # Recommended fix for build issue with clang.
    if koopa_is_macos
    then
        koopa_append_cflags '-Wno-implicit-function-declaration'
    fi
    dict['url']="https://downloads.sourceforge.net/project/zsh/zsh/\
${dict['version']}/zsh-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
