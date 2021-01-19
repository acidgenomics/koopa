#!/usr/bin/env bash

koopa::install_rbenv_ruby() { # {{{1
    # """
    # Install latest verison of Ruby in rbenv.
    # @note Updated 2020-07-08.
    #
    # > rbenv install -l
    # > rbenv versions
    #
    # Ensure installation uses system OpenSSL.
    # > export RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr
    # """
    local name_fancy version
    koopa::assert_is_installed rbenv
    version="$(koopa::variable ruby)"
    # Ensure '2.6.5p' becomes '2.6.5', for example.
    version="$(koopa::sanitize_version "$version")"
    name_fancy="Ruby ${version}"
    koopa::install_start "$name_fancy"
    # Ensure ruby-build is current.
    ruby_build_dir="$(koopa::rbenv_prefix)/plugins/ruby-build"
    if [[ -d "$ruby_build_dir" ]]
    then
        koopa::note "Updating ruby-build plugin: '${ruby_build_dir}'."
        (
            koopa::cd "$ruby_build_dir"
            git pull --quiet
        )
    fi
    rbenv install "$version"
    rbenv global "$version"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2020-12-31.
    # """
    koopa::assert_has_no_envs
    koopa::is_installed gem || return 0
    name_fancy='Ruby gems'
    koopa::install_start "$name_fancy"
    gemdir="$(gem environment gemdir)"
    koopa::dl 'Target' "$gemdir"
    if [[ "$#" -eq 0 ]]
    then
        # > gem pristine --all --only-executables
        gems=(
            # neovim
            'bashcov'
            'ronn'
        )
    else
        gems=("$@")
    fi
    koopa::dl 'Gems' "$(koopa::to_string "${gems[@]}")"
    for gem in "${gems[@]}"
    do
        gem install "$gem"
    done
    koopa::install_success "$name_fancy"
    return 0
}

