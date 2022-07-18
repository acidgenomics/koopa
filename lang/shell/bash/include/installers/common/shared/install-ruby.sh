#!/usr/bin/env bash

main() {
    # """
    # Install Ruby.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_opt_prefix 'openssl3'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='ruby'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    dict[version]="$(koopa_sanitize_version "${dict[version]}")"
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://cache.ruby-lang.org/pub/${dict[name]}/\
${dict[maj_min_ver]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # This will fail on Ubuntu 18 otherwise:
    # - https://github.com/rbenv/ruby-build/issues/156
    # - https://github.com/rbenv/ruby-build/issues/729
    # > export RUBY_CONFIGURE_OPTS='--disable-install-doc'
    conf_args=("--prefix=${dict[prefix]}")
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
