#!/usr/bin/env bash

# FIXME Currently error on macOS after openblas build step.

main() {
    # """
    # Install Julia (from source).
    # @note Updated 2022-09-30.
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
        # deps: none.
        'zlib'
        # deps: none.
        'zstd'
        # deps: none.
        'ca-certificates'
        # deps: ca-certificates.
        'openssl3'
        # deps: ca-certificates, openssl3, zlib, zstd.
        'curl'
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
        # deps: gmp, mpfr, mpc.
        'gcc' # gfortran
        # deps: gcc.
        'lapack'
        # deps: gcc.
        'openblas'
        # deps: none.
        'utf8proc'
        'llvm'
    )
    if ! koopa_is_macos
    then
        koopa_activate_opt_prefix "${deps[@]}"
    fi
    declare -A app=(
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python --realpath)"
    )
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='julia'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}-full.tar.gz"
    dict['url']="https://github.com/JuliaLang/julia/releases/download/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Customize the 'Make.user' file. Refer to 'Make.inc' for supported values.
    if koopa_is_macos
    then
        read -r -d '' "dict[make_user_string]" << END || true
VERBOSE=1
USE_BINARYBUILDER=1
END
    else
        read -r -d '' "dict[make_user_string]" << END || true
prefix=${dict['prefix']}
libexecdir=${dict['prefix']}/lib
sysconfdir=${dict['prefix']}/etc

VERBOSE=1
USE_BINARYBUILDER=0

USE_LLVM_SHLIB=1

DISABLE_LIBUNWIND=0
UNTRUSTED_SYSTEM_LIBM=0

USE_SYSTEM_BLAS=1
USE_SYSTEM_CSL=1
USE_SYSTEM_CURL=1
USE_SYSTEM_DSFMT=1
USE_SYSTEM_GMP=1
USE_SYSTEM_LAPACK=1
USE_SYSTEM_LIBBLASTRAMPOLINE=1
USE_SYSTEM_LIBGIT2=1
USE_SYSTEM_LIBM=1
USE_SYSTEM_LIBSSH2=1
USE_SYSTEM_LIBSUITESPARSE=1
USE_SYSTEM_LIBUNWIND=1
USE_SYSTEM_LIBUV=1
USE_SYSTEM_LIBWHICH=1
USE_SYSTEM_LLVM=1
USE_SYSTEM_MBEDTLS=1
USE_SYSTEM_MPFR=1
USE_SYSTEM_NGHTTP2=1
USE_SYSTEM_OPENLIBM=1
USE_SYSTEM_OPENSPECFUN=1
USE_SYSTEM_P7ZIP=1
USE_SYSTEM_PATCHELF=1
USE_SYSTEM_PCRE=1
USE_SYSTEM_UTF8PROC=1
USE_SYSTEM_ZLIB=1

# FIXME Is this not in use any more?
# > USE_BLAS64=1

# These options seem to have been removed.
# > USE_SYSTEM_ARPACK=1
# > USE_SYSTEM_FFTW=1
# > USE_SYSTEM_SUITESPARSE=1

LIBBLAS=-lopenblas
LIBBLASNAME=libopenblas
LIBLAPACK=-lopenblas
LIBLAPACKNAME=libopenblas

# > LLVM_CONFIG=\${LLVM_CONFIG}
# > LLVM_VER=\${LLVM_VER}

PYTHON=\${app['python']}
END
    fi
    koopa_write_string \
        --file='Make.user' \
        --string="${dict['make_user_string']}"
    koopa_add_to_path_end '/usr/sbin'
    koopa_print_env
    koopa_print "${dict['make_user_string']}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
