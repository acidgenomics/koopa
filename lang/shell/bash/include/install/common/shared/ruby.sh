#!/usr/bin/env bash

# FIXME This isn't building correctly on macOS Ventura...

main() {
    # """
    # Install Ruby.
    # @note Updated 2022-07-20.
    #
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib' 'openssl3'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='ruby'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    dict['version']="$(koopa_sanitize_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://cache.ruby-lang.org/pub/${dict['name']}/\
${dict['maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # This will fail on Ubuntu 18 otherwise:
    # - https://github.com/rbenv/ruby-build/issues/156
    # - https://github.com/rbenv/ruby-build/issues/729
    # > export RUBY_CONFIGURE_OPTS='--disable-install-doc'
    # FIXME May need to set a modified version of this for correct config
    # (see '--with-opt-dir' argument).
    # > paths = %w[libyaml openssl@1.1 readline].map { |f| Formula[f].opt_prefix }
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        '--enable-shared'
        '--without-gmp'
        # > FIXME --with-sitedir=#{HOMEBREW_PREFIX}/lib/ruby/site_ruby
        # > FIXME --with-vendordir=#{HOMEBREW_PREFIX}/lib/ruby/vendor_ruby
        # > FIXME --with-opt-dir=#{paths.join(":")}
    )
    koopa_is_macos && conf_args+=('--enable-dtrace')
    # Correct MJIT_CC to not use superenv shim
    # FIXME args << "MJIT_CC=/usr/bin/#{DevelopmentTools.default_compiler}"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
