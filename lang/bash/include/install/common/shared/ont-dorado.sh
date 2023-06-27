#!/usr/bin/env bash

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-06-27.
    #
    # @seealso
    # - https://github.com/nanoporetech/dorado/blob/master/CMakeLists.txt
    # - https://github.com/nanoporetech/dorado/blob/master/cmake/HDF5.cmake
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['arch']="$(koopa_arch)"
    if koopa_is_macos
    then
        koopa_assert_is_aarch64
        dict['platform']='osx'
    else
        dict['platform']='linux'
    fi
    case "${dict['arch']}" in
        'aarch64')
            dict['arch']='arm64'
            ;;
        'x86_64')
            dict['arch']='x64'
            ;;
    esac
    dict['url']="https://cdn.oxfordnanoportal.com/software/analysis/\
dorado-${dict['version']}-${dict['platform']}-${dict['arch']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")"
    koopa_stop "$PWD"
    return 0
}
