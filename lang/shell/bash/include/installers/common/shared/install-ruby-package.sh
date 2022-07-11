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
    # Alternative approach using gem:
    # > "${app[gem]}" install \
    # >     "${dict[name]}" \
    # >     --version "${dict[version]}" \
    # >     --install-dir "${dict[prefix]}"
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
    # - https://stackoverflow.com/questions/16098757/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bundle]="$(koopa_locate_bundle)"
        [ruby]="$(koopa_locate_ruby)"
    )
    [[ -x "${app[bundle]}" ]] || return 1
    [[ -x "${app[ruby]}" ]] || return 1
    app[ruby]="$(koopa_realpath "${app[ruby]}")"
    declare -A dict=(
        [gemfile]='Gemfile'
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[gemfile_string]="\
source \"https://rubygems.org\"\n\
gem \"${dict[name]}\", \"${dict[version]}\""
    dict[libexec]="${dict[prefix]}/libexec"
    koopa_mkdir "${dict[libexec]}"
    unset -v GEM_HOME GEM_PATH
    (
        koopa_cd "${dict[libexec]}"
        koopa_write_string \
            --file="${dict[gemfile]}" \
            --string="${dict[gemfile_string]}"
        "${app[bundle]}" install \
            --gemfile="${dict[gemfile]}" \
            --jobs="${dict[jobs]}" \
            --retry=3 \
            --standalone
        "${app[bundle]}" binstubs \
            "${dict[name]}" \
            --path="${dict[prefix]}/bin" \
            --shebang="${app[ruby]}" \
            --standalone
    )
    return 0
}
