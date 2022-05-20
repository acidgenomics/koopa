#!/usr/bin/env bash

main() {
    # """
    # Install Ruby packages (gems).
    # @note Updated 2022-04-14.
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
        [prefix]="${INSTALL_PREFIX:?}"
    )
    GEM_HOME="${dict[prefix]}"
    export GEM_HOME
    gems=(
        # > 'neovim'
        'bundler'
        'bashcov'
        'colorls'
        'ronn'
    )
    "${app[gem]}" cleanup
    for gem in "${gems[@]}"
    do
        "${app[gem]}" install "$gem"
    done
    "${app[gem]}" cleanup
    return 0
}
