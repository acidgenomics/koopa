#!/usr/bin/env bash

# FIXME This is currently failing for 1.8.0.
# Install from source is very complicated.

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
    # - https://ports.macports.org/port/julia/details/
    # - https://git.alpinelinux.org/aports/tree/community/julia/APKBUILD?h=3.6-stable
    # """
    local app build_deps deps dict
    koopa_assert_has_no_args "$#"
    build_deps=(
        'cmake'
        'bzip2'
        'tar'
        'xz'
    )
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    deps=(
    # >     # deps: none.
    # >     'zlib'
    # >     # deps: none.
    # >     'zstd'
    # >     # deps: none.
    # >     'ca-certificates'
    # >     # deps: ca-certificates.
    # >     'openssl3'
    # >     # deps: ca-certificates, openssl3, zlib, zstd.
    # >     'curl'
    # >     # deps: bzip2, zlib.
    # >     'pcre2'
    # >     # deps: openssl3.
    # >     'libssh2'
    # >     # deps: libssh2, openssl3, pcre, zlib.
    # >     'libgit2'
    # >     # deps: m4.
    # >     'gmp'
    # >     # deps: gmp.
    # >     'mpfr'
    # >     # deps: gmp, mpfr, mpc.
        'gcc' # gfortran
    # >     # deps: gcc.
    # >     'lapack'
    # >     # deps: gcc.
    # >     'openblas'
    # >     # deps: none.
    # >     'utf8proc'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [make]="$(koopa_locate_make)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[cat]}" ]] || return 1
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    app[python]="$(koopa_realpath "${app[python]}")"
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
libexecdir=${dict[prefix]}/lib
sysconfdir=${dict[prefix]}/etc

VERBOSE=1
USE_BINARYBUILDER=0

USE_SYSTEM_ARPACK=0
USE_SYSTEM_BLAS=0 # 1
USE_SYSTEM_CSL=0
USE_SYSTEM_CURL=0 # 1
USE_SYSTEM_DSFMT=0
USE_SYSTEM_FFTW=0
USE_SYSTEM_GMP=0 # 1
USE_SYSTEM_LAPACK=0 # 1
USE_SYSTEM_LIBGIT2=0 # 1
USE_SYSTEM_LIBM=0
USE_SYSTEM_LIBSSH2=0 # 1
USE_SYSTEM_LIBSUITESPARSE=0
USE_SYSTEM_LIBUNWIND=0
USE_SYSTEM_LIBUV=0
USE_SYSTEM_LLVM=0
USE_SYSTEM_MBEDTLS=0
USE_SYSTEM_MPFR=0 # 1
USE_SYSTEM_NGHTTP2=0
USE_SYSTEM_OPENLIBM=0
USE_SYSTEM_OPENSPECFUN=0
USE_SYSTEM_P7ZIP=0
USE_SYSTEM_PATCHELF=0
USE_SYSTEM_PCRE=0 # 1
USE_SYSTEM_SUITESPARSE=0
USE_SYSTEM_UTF8PROC=0 # 1
USE_SYSTEM_ZLIB=0 # 1

# > USE_BLAS64=0
# > USE_LLVM_SHLIB=0

# > LIBBLAS=-lopenblas
# > LIBBLASNAME=libopenblas
# > LIBLAPACK=-lopenblas
# > LIBLAPACKNAME=libopenblas

# > LLVM_CONFIG=\$LLVM_CONFIG
# > LLVM_VER=\$LLVM_VER

PYTHON=${app[python]}"
END
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
