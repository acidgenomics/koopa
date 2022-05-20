#!/usr/bin/env bash

main() {
    # """
    # Install Julia (from source).
    # @note Updated 2022-04-09.
    #
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='julia'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # > dict[file]="v${dict[version]}.tar.gz"
    # > dict[url]="https://github.com/JuliaLang/${dict[name]}/\
    # >     archive/${dict[file]}"
    dict[file]="${dict[name]}-${dict[version]}-full.tar.gz"
    dict[url]="https://github.com/JuliaLang/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # If set, this will interfere with internal LLVM build required for
    # Julia. See 'build.md' file for LLVM details.
    unset -v LLVM_CONFIG
    # Customize the 'Make.user' file.
    # Need to ensure we configure internal LLVM build here.
    cat > 'Make.user' << END
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
    app[julia]="${dict[prefix]}/bin/julia"
    koopa_assert_is_installed "${app[julia]}"
    koopa_configure_julia "${app[julia]}"
    return 0
}
