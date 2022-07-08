#!/usr/bin/env bash

# FIXME Need to version pin the programs here.
# FIXME Can we install a Ruby gem into an isolated directory?
# FIXME Use the '--version' argument to do this.
# FIXME For Ruby 1.9+ use ':' here.

# FIXME Just set GEM_HOME here.

main() {
    # """
    # Install Ruby packages (gems).
    # @note Updated 2022-07-06.
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
        local version
        version="$(koopa_variable "ruby-${gem}")"
        # Alternatively, can use "${gem}:${version}" format here.
        "${app[gem]}" install "$gem" --version "$version"
    done
    "${app[gem]}" cleanup
    return 0
}
