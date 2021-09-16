#!/usr/bin/env bash

# FIXME Need to wrap in 'install_app' call.
koopa::install_ruby_packages() { # {{{1
}


koopa:::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2021-09-16.
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local default gemdir gem gems name_fancy ruby ruby_version
    koopa::assert_has_no_envs
    ruby="$(koopa::locate_ruby)"
    ruby_version="$(koopa::get version "$ruby")"
    # FIXME Need to locate ruby and specify the version here.
    koopa::activate_ruby
    # FIXME This step will likely fail, need to point to gem.
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

koopa::uninstall_ruby_packages() { # {{{1
    # """
    # Uninstall Ruby packages.
    # @note Updated 2021-06-14.
    # """
    koopa:::uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        --no-link \
        "$@"
}

koopa::update_ruby_packages() {  # {{{1
    # """
    # Update Ruby packages.
    # @note Updated 2021-02-15.
    # """
    koopa::install_ruby_packages "$@"
    return 0
}
