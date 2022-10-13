#!/usr/bin/env bash

# NOTE 1.1.1q currently fails to build on macOS.

main() {
    # """
    # Install OpenSSL.
    # @note Updated 2022-08-27.
    #
    # @seealso
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     openssl@1.1.rb
    # - https://stackoverflow.com/questions/4138139/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'ca-certificates'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='openssl'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.openssl.org/source/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--openssldir=${dict['prefix']}"
        "--prefix=${dict['prefix']}"
        "-Wl,-rpath,${dict['prefix']}/lib"
        'no-ssl3'
        'no-ssl3-method'
        'no-zlib'
        'shared'
    )
    # The '-fPIC' flag is required for non-prefixed configuration arguments,
    # such as 'no-shared' or 'shared' to be detected correctly.
    export CPPFLAGS="${CPPFLAGS:-} -fPIC"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./config "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    dict['ca_certificates']="$(koopa_app_prefix 'ca-certificates')"
    dict['cacert']="${dict['ca_certificates']}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict['cacert']}"
    koopa_ln \
        "${dict['cacert']}" \
        "${dict['prefix']}/certs/cacert.pem"
    app['openssl']="${dict['prefix']}/bin/openssl"
    koopa_assert_is_installed "${app['openssl']}"
    "${app['openssl']}" version -d
    koopa_check_shared_object --file="${dict['prefix']}/bin/openssl"
    return 0
}
