#!/usr/bin/env bash

main() {
    # """
    # Install CMake.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # - https://github.com/conda-forge/cmake-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cmake.rb
    # """
    local -A app dict
    local -a bootstrap_args cmake_args
    koopa_activate_app --build-only 'make'
    koopa_activate_app 'openssl'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    koopa_is_linux && dict['jobs']=1
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=7
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    readarray -t cmake_args <<< "$( \
        koopa_cmake_std_args --prefix="${dict['prefix']}" \
    )"
    cmake_args+=(
        '-DCMake_BUILD_LTO=ON'
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
    )
    bootstrap_args=(
        '--no-system-libs'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
    )
    # > if koopa_is_macos
    # > then
    # >     bootstrap_args+=(
    # >         '--system-bzip2'
    # >         '--system-curl'
    # >         '--system-zlib'
    # >     )
    # > fi
    bootstrap_args+=('--' "${cmake_args[@]}")
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    dict['url']="https://github.com/Kitware/CMake/releases/download/\
v${dict['version']}/cmake-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Fix bundled curl for OpenSSL 4 compatibility.
    # OpenSSL 4 made ASN1_STRING an opaque type, so direct struct member
    # access must be replaced with accessor functions.
    if [[ -f 'Utilities/cmcurl/lib/vtls/openssl.c' ]]
    then
        koopa_find_and_replace_in_file \
            --regex \
            --pattern='num->type' \
            --replacement='ASN1_STRING_type(num)' \
            'Utilities/cmcurl/lib/vtls/openssl.c'
        koopa_find_and_replace_in_file \
            --regex \
            --pattern='num->length' \
            --replacement='ASN1_STRING_length(num)' \
            'Utilities/cmcurl/lib/vtls/openssl.c'
        koopa_find_and_replace_in_file \
            --regex \
            --pattern='num->data' \
            --replacement='ASN1_STRING_get0_data(num)' \
            'Utilities/cmcurl/lib/vtls/openssl.c'
        koopa_find_and_replace_in_file \
            --regex \
            --pattern='psig->length' \
            --replacement='ASN1_STRING_length(psig)' \
            'Utilities/cmcurl/lib/vtls/openssl.c'
        koopa_find_and_replace_in_file \
            --regex \
            --pattern='psig->data' \
            --replacement='ASN1_STRING_get0_data(psig)' \
            'Utilities/cmcurl/lib/vtls/openssl.c'
    fi
    ./bootstrap --help || true
    ./bootstrap "${bootstrap_args[@]}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
