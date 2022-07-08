#!/usr/bin/env bash

# FIXME This isn't installing with isolation correctly.
# shcov (Gem::GemNotFoundException)
# 	from /opt/koopa/app/ruby/3.1.2p20/lib/ruby/3.1.0/rubygems.rb:284:in `activate_bin_path'
# 	from /opt/koopa/bin/bashcov:25:in `<main>'
# FIXME Do we need to use bundle to accomplish this?

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
    # - https://bundler.io/bundle_install.html
    # - https://textplain.org/p/ruby-isolated-environments
    # - https://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/
    # - https://coderwall.com/p/rz7sqa/keeping-your-bundler-gems-isolated
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bundle]="$(koopa_locate_bundle)"
    )
    [[ -x "${app[bundle]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    export GEM_HOME="${dict[prefix]}"
    "${app[bundle]}" install \
        --binstubs \
        --jobs "${dict[jobs]}" \
        --path "${dict[prefix]}" \
        "${dict[name]}" \
        --version "${dict[version]}"
    return 0
}
