#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://www.openssl.org/docs/man3.0/man7/migration_guide.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/openssl@3.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    unset -v OPENSSL_LOCAL_CONFIG_DIR
    declare -A app=(
        [ldd]="$(koopa_locate_ldd)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [link_in_make]="${INSTALL_LINK_IN_MAKE:?}"
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
    conf_args=(
        "--prefix=${dict[prefix]}"
        "--openssldir=${dict[prefix]}"
        'no-comp'
        'no-ssl2'
        'no-ssl3'
    )
    case "${dict[link_in_make]}" in
        '0')
            conf_args+=('no-shared')
            ;;
        '1')
            conf_args+=('shared')
            ;;
    esac
    # Check supported platforms with:
    # > ./Configure LIST
    ./config "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # Verify the settings stuck.
    # > if koopa_is_linux
    # > then
    # >     readelf -d './libssl.so' | grep -i -E 'rpath|runpath'
    # > fi
    "${app[make]}" test
    "${app[make]}" install
    if koopa_is_macos
    then
        app[otool]="$(koopa_macos_locate_otool)"
        "${app[otool]}" -L "${dict[prefix]}/lib/libssl.so"
        "${app[otool]}" -L "${dict[prefix]}/bin/openssl"
    elif koopa_is_linux
    then
        app[ldd]="$(koopa_locate_ldd)"
        "${app[ldd]}" "${dict[prefix]}/lib/libssl.so"
        "${app[ldd]}" "${dict[prefix]}/bin/openssl"
    fi
    return 0
}
