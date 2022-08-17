#!/usr/bin/env bash

# NOTE Work on improving recipe, based on Homebrew:
#
# # Requires the M1 fork of GCC to build
# # https://github.com/JuliaLang/julia/issues/36617
# depends_on arch: :x86_64
# depends_on "ca-certificates"
# depends_on "curl"
# depends_on "gcc" # for gfortran
# depends_on "gmp"
# depends_on "libgit2"
# depends_on "libnghttp2"
# depends_on "libssh2"
# depends_on "llvm@13"
# depends_on "mbedtls@2"
# depends_on "mpfr"
# depends_on "openblas"
# depends_on "openlibm"
# depends_on "p7zip"
# depends_on "pcre2"
# depends_on "suite-sparse"
# depends_on "utf8proc"
#
# uses_from_macos "perl" => :build
# uses_from_macos "python" => :build
# uses_from_macos "zlib"
#
# on_linux do
#   depends_on "patchelf" => :build
#   # This dependency can be dropped when upstream resolves
#   # https://github.com/JuliaLang/julia/issues/30154
#   depends_on "libunwind"
# end

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
        'zlib'
        'pcre2'
        'gcc'
        'openssl3'
        'libgit2'
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
# > USE_BINARYBUILDER=0
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
END
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
