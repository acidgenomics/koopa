#!/usr/bin/env bash

# FIXME Can we isolate with this approach?
# bundler install --binstubs --path vendor
# bundle install --jobs 4

# https://bundler.io/bundle_install.html
# https://textplain.org/p/ruby-isolated-environments
# https://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/
# https://coderwall.com/p/rz7sqa/keeping-your-bundler-gems-isolated


main() {
    # """
    # Install Ruby package.
    # @note Updated 2022-07-08.
    #
    # Alternatively, can use "${dict[name]}:${dict[version]}" format here.
    #
    # @seealso
    # - 'gem pristine --all'
    # - 'gem update --system'
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gem]="$(koopa_locate_gem)"
    )
    [[ -x "${app[gem]}" ]] || return 1
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    export GEM_HOME="${dict[prefix]}"
    "${app[gem]}" install "${dict[name]}" --version "${dict[version]}"
    return 0
}
