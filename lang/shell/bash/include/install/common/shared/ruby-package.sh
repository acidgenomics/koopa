#!/usr/bin/env bash

main() {
    # """
    # Install Ruby package.
    # @note Updated 2022-07-11.
    #
    # Alternative approach using gem:
    # > "${app['gem']}" install \
    # >     "${dict['name']}" \
    # >     --version "${dict['version']}" \
    # >     --install-dir "${dict['prefix']}"
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
        ['bundle']="$(koopa_locate_bundle)"
        ['ruby']="$(koopa_locate_ruby)"
    )
    [[ -x "${app['bundle']}" ]] || return 1
    [[ -x "${app['ruby']}" ]] || return 1
    app['ruby']="$(koopa_realpath "${app['ruby']}")"
    declare -A dict=(
        ['gemfile']='Gemfile'
        ['jobs']="$(koopa_cpu_count)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    read -r -d '' "dict[gemfile_string]" << END || true
source "https://rubygems.org"
gem "${dict['name']}", "${dict['version']}"
END
    dict['libexec']="${dict['prefix']}/libexec"
    koopa_mkdir "${dict['libexec']}"
    (
        koopa_cd "${dict['libexec']}"
        koopa_write_string \
            --file="${dict['gemfile']}" \
            --string="${dict['gemfile_string']}"
        "${app['bundle']}" install \
            --gemfile="${dict['gemfile']}" \
            --jobs="${dict['jobs']}" \
            --retry=3 \
            --standalone
        "${app['bundle']}" binstubs \
            "${dict['name']}" \
            --path="${dict['prefix']}/bin" \
            --shebang="${app['ruby']}" \
            --standalone
    )
    return 0
}
