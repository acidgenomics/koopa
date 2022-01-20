#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
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
