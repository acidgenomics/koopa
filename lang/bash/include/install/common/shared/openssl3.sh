#!/usr/bin/env bash

main() {
    # """
    # Install OpenSSL.
    # @note Updated 2024-09-09.
    #
    # Check supported platforms with:
    # > ./Configure LIST
    #
    # @seealso
    # - https://openssl-library.org/source/
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://www.openssl.org/docs/man3.0/man7/migration_guide.html
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/2537271/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/openssl@3.rb
    # - https://gist.github.com/fumiyas/b4aaee83e113e061d1ee8ab95b35608b
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'ca-certificates'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['ca_certificates']="$(koopa_app_prefix 'ca-certificates')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cacert']="${dict['ca_certificates']}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict['cacert']}"
    conf_args=(
        '--libdir=lib'
        "--openssldir=${dict['prefix']}"
        "--prefix=${dict['prefix']}"
        "-Wl,-rpath,${dict['prefix']}/lib"
        'no-zlib'
        'shared'
    )
    if koopa_is_linux
    then
        conf_args+=('-Wl,--enable-new-dtags')
    fi
    koopa_append_cppflags '-fPIC'
    dict['url']="https://github.com/openssl/openssl/releases/download/\
openssl-${dict['version']}/openssl-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./config --help
    ./config "${conf_args[@]}"
    "${app['make']}" --jobs=1 depend
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install_sw
    # Manually delete static libraries.
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    koopa_ln \
        "${dict['cacert']}" \
        "${dict['prefix']}/certs/cacert.pem"
    app['openssl']="${dict['prefix']}/bin/openssl"
    koopa_assert_is_installed "${app['openssl']}"
    "${app['openssl']}" version -d
    koopa_check_shared_object --file="${dict['prefix']}/bin/openssl"
    return 0
}
