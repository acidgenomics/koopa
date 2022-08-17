#!/usr/bin/env bash

main() {
    # """
    # Install Julia (from source).
    # @note Updated 2022-07-18.
    #
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/julia.rb
    # """
    local app deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    deps=(
        # deps: none.
        'zlib'
        # deps: none.
        'zstd'
        # deps: none.
        'bzip2'
        # deps: none.
        'tar'
        # deps: none.
        'xz'
        # deps: none.
        'ca-certificates'
        # deps: ca-certificates.
        'openssl3'
        # deps: ca-certificates, openssl3, zlib, zstd.
        'curl'
        # deps: bzip2, zlib.
        # > 'pcre'
        # deps: bzip2, zlib.
        'pcre2'
        # deps: openssl3.
        'libssh2'
        # deps: libssh2, openssl3, pcre, zlib.
        'libgit2'
        # deps: m4.
        'gmp'
        # deps: gmp.
        'mpfr'
        # deps: gmp, mpfr.
        # > 'mpc'
        # deps: gmp, mpfr, mpc.
        'gcc' # gfortran
        # deps: gcc.
        'openblas'
        # deps: none.
        'utf8proc'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[cat]}" ]] || return 1
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='julia'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/JuliaLang/julia/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # If set, this will interfere with internal LLVM build required for
    # Julia. See 'build.md' file for LLVM details.
    unset -v LLVM_CONFIG
    # Customize the 'Make.user' file.
    # Need to ensure we configure internal LLVM build here.
    "${app[cat]}" > 'Make.user' << END
prefix=${dict[prefix]}
# > LLVM_ASSERTIONS=1
# > LLVM_DEBUG=Release

USE_BINARYBUILDER=0
VERBOSE=1

# > USE_SYSTEM_LLVM=1
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0

# > USE_BLAS64=0
# > USE_SYSTEM_BLAS=1
# > USE_SYSTEM_CSL=1
# > USE_SYSTEM_CURL=1
# > USE_SYSTEM_GMP=1
# > USE_SYSTEM_LAPACK=1
# > USE_SYSTEM_LIBGIT2=1
# > USE_SYSTEM_LIBSSH2=1
# > USE_SYSTEM_LIBSUITESPARSE=1
# > USE_SYSTEM_LIBUNWIND=1
# > USE_SYSTEM_MBEDTLS=1
# > USE_SYSTEM_MPFR=1
# > USE_SYSTEM_NGHTTP2=1
# > USE_SYSTEM_OPENLIBM=1
# > USE_SYSTEM_P7ZIP=1
# > USE_SYSTEM_PATCHELF=1
# > USE_SYSTEM_PCRE=1
# > USE_SYSTEM_UTF8PROC=1
# > USE_SYSTEM_ZLIB=1

# > LIBBLAS=-lopenblas
# > LIBBLASNAME=libopenblas
# > LIBLAPACK=-lopenblas
# > LIBLAPACKNAME=libopenblas
# > PYTHON=python3
END
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
