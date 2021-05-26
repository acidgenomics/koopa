#!/usr/bin/env bash

koopa::install_ruby() { # {{{1
    koopa::install_app \
        --name='ruby' \
        --name-fancy='Ruby' \
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

koopa::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2021-05-25.
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local default gemdir gem gems name_fancy
    koopa::assert_has_no_envs
    koopa::activate_ruby
    koopa::configure_ruby
    koopa::assert_is_installed 'gem'
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'libffi'
    fi
    name_fancy='Ruby gems'
    koopa::install_start "$name_fancy"
    gemdir="$(gem environment gemdir)"
    koopa::dl 'Target' "$gemdir"
    if [[ "$#" -eq 0 ]]
    then
        default=1
        gems=(
            # > 'neovim'
            'bundler'
            'bashcov'
            'ronn'
        )
    else
        default=0
        gems=("$@")
    fi
    koopa::dl 'Gems' "$(koopa::to_string "${gems[@]}")"
    if [[ "$default" -eq 1 ]]
    then
        gem cleanup
        gem pristine --all
        if koopa::is_shared_install
        then
            gem update --system
        fi
    fi
    for gem in "${gems[@]}"
    do
        gem install "$gem"
    done
    if [[ "$default" -eq 1 ]]
    then
        gem cleanup
    fi
    koopa::sys_set_permissions -r "$gemdir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_ruby_packages() {  # {{{1
    # """
    # Update Ruby packages.
    # @note Updated 2021-02-15.
    # """
    koopa::install_ruby_packages "$@"
    return 0
}
