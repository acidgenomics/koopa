#!/usr/bin/env bash

install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2022-02-10.
    #
    # @seealso
    # - 'gem pristine --all'
    # - 'gem update --system'
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app dict gem gems
    koopa_assert_has_no_args "$#"
    koopa_activate_ruby
    declare -A app=(
        [gem]="$(koopa_locate_gem)"
    )
    declare -A dict=(
        [gemdir]="$("${app[gem]}" environment 'gemdir')"
    )
    gems=(
        # > 'neovim'
        'bundler'
        'bashcov'
        'ronn'
    )
    koopa_dl \
        'Target' "${dict[gemdir]}" \
        'Gems' "$(koopa_to_string "${gems[@]}")"
    if koopa_is_macos
    then
        koopa_activate_homebrew_opt_prefix 'libffi'
    fi
    "${app[gem]}" cleanup
    for gem in "${gems[@]}"
    do
        "${app[gem]}" install "$gem"
    done
    "${app[gem]}" cleanup
    return 0
}
