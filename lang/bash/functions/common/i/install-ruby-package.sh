#!/usr/bin/env bash

koopa_install_ruby_package() {
    # """
    # Install Ruby package.
    # @note Updated 2023-08-29.
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
    local -A app dict
    koopa_assert_is_install_subshell
    app['bundle']="$(koopa_locate_bundle)"
    app['ruby']="$(koopa_locate_ruby --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['gemfile']='Gemfile'
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    read -r -d '' "dict[gemfile_string]" << END || true
source "https://rubygems.org"
gem "${dict['name']}", "${dict['version']}"
END
    dict['libexec']="${dict['prefix']}/libexec"
    koopa_mkdir "${dict['libexec']}"
    koopa_print_env
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
