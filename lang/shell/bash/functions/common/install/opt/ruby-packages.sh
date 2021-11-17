#!/usr/bin/env bash

koopa::install_ruby_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa:::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2021-09-16.
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app apps default gemdir gem
    koopa::configure_ruby
    koopa::activate_ruby
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'libffi'
    fi
    if [[ "$#" -eq 0 ]]
    then
        default=1
        apps=(
            # > 'neovim'
            'bundler'
            'bashcov'
            'ronn'
        )
    else
        default=0
        apps=("$@")
    fi
    gem="$(koopa::locate_gem)"
    gemdir="$("$gem" environment gemdir)"
    koopa::dl \
        'Target' "$gemdir" \
        'Gems' "$(koopa::to_string "${apps[@]}")"
    if [[ "$default" -eq 1 ]]
    then
        "$gem" cleanup
        "$gem" pristine --all
        # > if koopa::is_shared_install
        # > then
        # >     "$gem" update --system
        # > fi
    fi
    for app in "${apps[@]}"
    do
        "$gem" install "$app"
    done
    if [[ "$default" -eq 1 ]]
    then
        "$gem" cleanup
    fi
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
}
