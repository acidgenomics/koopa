#!/usr/bin/env bash

koopa_cmake_std_args() {
    # """
    # Standard CMake arguments.
    # @note Updated 2023-05-17.
    #
    # Potentially useful:
    # - CMAKE_STATIC_LINKER_FLAGS
    #
    # @seealso
    # - https://github.com/Homebrew/brew/blob/64259a420b666744dffb126a79781520bd
    #   266fc6/Library/Homebrew/formula.rb#L1557
    # - https://bytefreaks.net/programming-2/make-building-with-cmake-verbose
    # """
    local -A dict
    local -a args
    koopa_assert_has_args "$#"
    dict['bin_dir']=''
    dict['include_dir']=''
    dict['lib_dir']=''
    dict['prefix']=''
    dict['rpath']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
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
            '--rpath='*)
                dict['rpath']="${1#*=}"
                shift 1
                ;;
            '--rpath')
                dict['rpath']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    [[ -z "${dict['bin_dir']}" ]] && \
        dict['bin_dir']="${dict['prefix']}/bin"
    [[ -z "${dict['include_dir']}" ]] && \
        dict['include_dir']="${dict['prefix']}/include"
    [[ -z "${dict['lib_dir']}" ]] && \
        dict['lib_dir']="${dict['prefix']}/lib"
    [[ -z "${dict['rpath']}" ]] && \
        dict['rpath']="${dict['prefix']}/lib"
    args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_BINDIR=${dict['bin_dir']}"
        "-DCMAKE_INSTALL_INCLUDEDIR=${dict['include_dir']}"
        "-DCMAKE_INSTALL_LIBDIR=${dict['lib_dir']}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['rpath']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Consider enabling:
        # > '-DCMAKE_RULE_MESSAGES=ON'
        # Additional options set by Homebrew by default:
        # > '-DCMAKE_FIND_FRAMEWORK=LAST'
        # > '-DBUILD_TESTING=OFF'
        # > '-Wno-dev'
    )
    if koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sdk_prefix']}"
        dict['sdk_prefix']="$(koopa_realpath "${dict['sdk_prefix']}")"
        args+=(
            '-DCMAKE_MACOSX_RPATH=ON'
            "-DCMAKE_OSX_SYSROOT=${dict['sdk_prefix']}"
        )
    fi
    koopa_print "${args[@]}"
    return 0
}
