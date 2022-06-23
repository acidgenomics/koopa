#!/usr/bin/env bash

main() {
    # """
    # Install OpenSSL.
    # @note Updated 2022-06-14.
    #
    # @seealso
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     openssl@1.1.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
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
    conf_args=(
        "--openssldir=${dict[prefix]}"
        "--prefix=${dict[prefix]}"
        "-Wl,-rpath,${dict[prefix]}/lib"
        'no-ssl3'
        'no-ssl3-method'
        'shared' # or 'no-shared'.
        'zlib'
    )
    # The '-fPIC' flag is required for non-prefixed configuration arguments,
    # such as 'no-shared' or 'shared' to be detected correctly.
    export CPPFLAGS="${CPPFLAGS:-} -fPIC"
    ./config "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
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
