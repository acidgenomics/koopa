#!/usr/bin/env bash

koopa:::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2022-01-25.
    #
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app dict gem gems
    koopa::configure_ruby
    koopa::activate_ruby
    declare -A app=(
        [gem]="$(koopa::locate_gem)"
    )
    declare -A dict=(
        [default]=0
        [gemdir]="$("${app[gem]}" environment 'gemdir')"
    )
    if [[ "$#" -eq 0 ]]
    then
        dict[default]=1
        gems=(
            # > 'neovim'
            'bundler'
            'bashcov'
            'ronn'
        )
    else
        dict[default]=0
        gems=("$@")
    fi
    koopa::dl \
        'Target' "${dict[gemdir]}" \
        'Gems' "$(koopa::to_string "${gems[@]}")"
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'libffi'
    fi
    if [[ "${dict[default]}" -eq 1 ]]
    then
        "${app[gem]}" cleanup
        "${app[gem]}" pristine --all
        # > if koopa::is_shared_install
        # > then
        # >     "${app[gem]}" update --system
        # > fi
    fi
    for gem in "${gems[@]}"
    do
        "${app[gem]}" install "$gem"
    done
    if [[ "${dict[default]}" -eq 1 ]]
    then
        "${app[gem]}" cleanup
    fi
    return 0
}
