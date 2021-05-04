#!/usr/bin/env bash

install_zsh() { # {{{1
    # """
    # Install Zsh.
    # @note Updated 2021-05-04.
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
    local etc_dir file jobs link_app name prefix url version
    link_app="${INSTALL_LINK_APP:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='zsh'
    jobs="$(koopa::cpu_count)"
    etc_dir="${prefix}/etc/${name}"
    file="${name}-${version}.tar.xz"
    # > url="ftp://ftp.fu-berlin.de/pub/unix/shells/${name}/${file}"
    url="https://downloads.sourceforge.net/project/\
${name}/${name}/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure \
        --prefix="$prefix" \
        --enable-etcdir="$etc_dir" \
        --without-tcsetpgrp
    make --jobs="$jobs"
    # > make check
    # > make test
    make install
    if koopa::is_debian_like
    then
        koopa::alert "Linking shared config scripts into '${etc_dir}'."
        koopa::ln \
            -t "${etc_dir}" \
            "$(koopa::distro_prefix)/etc/zsh/"*
    fi
    [[ "${link_app:-0}" -eq 1 ]] && koopa::enable_shell "$name"
    koopa::fix_zsh_permissions
    return 0
}

install_zsh "$@"
