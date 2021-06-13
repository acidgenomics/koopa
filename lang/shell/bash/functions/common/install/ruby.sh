#!/usr/bin/env bash

koopa::configure_ruby() { # {{{1
    # """
    # Configure Ruby.
    # @note Updated 2021-06-11.
    # """
    local name_fancy prefix version
    koopa::activate_ruby
    koopa::assert_is_installed 'ruby'
    name_fancy='Ruby'
    version="$(koopa::get_version 'ruby')"
    prefix="$(koopa::ruby_packages_prefix "$version")"
    koopa::configure_start "$name_fancy" "$prefix"
    if [[ ! -d "$prefix" ]]
    then
        koopa::sys_mkdir "$prefix"
        koopa::sys_set_permissions "$(koopa::dirname "$prefix")"
        koopa::link_into_opt "$prefix" 'ruby-packages'
    fi
    koopa::activate_ruby
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}

koopa::install_ruby() { # {{{1
    koopa::install_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa:::install_ruby() { # {{{1
    # """
    # Install Ruby.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='ruby'
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    version="$(koopa::sanitize_version "$version")"
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${version}.tar.gz"
    url="https://cache.ruby-lang.org/pub/${name}/${minor_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    # This will fail on Ubuntu 18 otherwise.
    # https://github.com/rbenv/ruby-build/issues/156
    # https://github.com/rbenv/ruby-build/issues/729
    export RUBY_CONFIGURE_OPTS='--disable-install-doc'
    ./configure --prefix="$prefix"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_ruby() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}
