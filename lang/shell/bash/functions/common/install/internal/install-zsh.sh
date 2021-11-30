#!/usr/bin/env bash

koopa:::install_zsh() { # {{{1
    # """
    # Install Zsh.
    # @note Updated 2021-11-30.
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
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [link_app]="${INSTALL_LINK_APP:?}"
        [name]='zsh'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[etc_dir]="${dict[prefix]}/etc/${dict[name]}"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://downloads.sourceforge.net/project/\
${dict[name]}/${dict[name]}/${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure \
        --prefix="${dict[prefix]}" \
        --enable-etcdir="${dict[etc_dir]}" \
        --without-tcsetpgrp
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    # > "${app[make]}" test
    "${app[make]}" install
    if koopa::is_debian_like
    then
        koopa::alert "Linking shared config scripts into '${dict[etc_dir]}'."
        dict[distro_prefix]="$(koopa::distro_prefix)"
        koopa::ln \
            -t "${dict[etc_dir]}" \
            "${dict[distro_prefix]}/etc/zsh/"*
    fi
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::enable_shell "${dict[name]}"
    fi
    return 0
}
