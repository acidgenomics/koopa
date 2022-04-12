#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://www.openssl.org/docs/man3.0/man7/migration_guide.html
    # - https://stackoverflow.com/questions/2537271/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/openssl@3.rb
    # - https://gist.github.com/fumiyas/b4aaee83e113e061d1ee8ab95b35608b
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'zlib'
    unset -v OPENSSL_LOCAL_CONFIG_DIR
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='openssl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.openssl.org/source/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # https://wiki.openssl.org/index.php/
    #   Compilation_and_Installation#Configure_Options
    # Check supported platforms with:
    # > ./Configure LIST
    conf_args=(
        "--prefix=${dict[prefix]}"
        "--openssldir=${dict[prefix]}"
        "-Wl,-rpath,${dict[prefix]}/lib64"
        'shared' # or 'no-shared'
        'zlib'
    )
    if koopa_is_linux
    then
        conf_args+=('-Wl,--enable-new-dtags')
    fi
    # The '-fPIC' flag is required for non-prefixed configuration arguments,
    # such as 'no-shared' or 'shared' to be detected correctly.
    export CPPFLAGS="${CPPFLAGS:-} -fPIC"
    ./config "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" test
    "${app[make]}" install
    if koopa_is_linux
    then
        app[ldd]="$(koopa_locate_ldd)"
        "${app[ldd]}" "${dict[prefix]}/bin/openssl"
    elif koopa_is_macos
    then
        app[otool]="$(koopa_macos_locate_otool)"
        "${app[otool]}" -L "${dict[prefix]}/bin/openssl"
    fi
    return 0
}
