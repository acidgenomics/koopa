#!/usr/bin/env bash

koopa::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2021-04-25.
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local default gemdir gem gems name_fancy
    koopa::assert_has_no_envs
    if ! koopa::is_installed gem
    then
        koopa::alert_note 'gem is not installed.'
        return 0
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
