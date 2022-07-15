#!/usr/bin/env bash

# NOTE Not yet suppored for ARM.

# FIXME Can we use these to isolate?
# '--with-gcc'

# FIXME Can we point to gmp with:
# --extra-include-dirs
# --extra-lib-dirs

# FIXME Consider setting '--no-install-ghc'.

main() {
    # """
    # Install Haskell Stack.
    # @note Updated 2022-07-15.
    #
    # @section Required system dependencies:
    #
    # Debian / Ubuntu:
    # > sudo apt-get install g++ gcc libc6-dev libffi-dev libgmp-dev make \
    # >   xz-utils zlib1g-dev git gnupg netbase
    # Fedora / CentOS:
    # > sudo dnf install perl make automake gcc gmp-devel libffi zlib \
    # >   zlib-devel xz tar git gnupg
    #
    # Arch Linux:
    # > sudo pacman -S make gcc ncurses git gnupg xz zlib gmp libffi zlib
    #
    # GHC will be installed at:
    # libexec/root/programs/x86_64-osx/ghc-9.0.2/bin
    #
    # Potentially useful arguments:
    # * '--allow-different-user'
    # * '--local-bin-path'
    # * '--stack-root'
    #
    # @seealso
    # - stack --help
    # - stack path
    # - stack exec env
    # - stack ghc, stack ghci, stack runghc, or stack exec
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # - https://docs.haskellstack.org/en/stable/GUIDE/
    # - https://github.com/commercialhaskell/stack/releases
    # """
    local app dict stack_args
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_opt_prefix 'gmp'
    declare -A app
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [jobs]="$(koopa_cpu_count)"
        [name]='stack'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    app[stack]="${dict[prefix]}/bin/stack"
    if koopa_is_linux
    then
        dict[platform]='linux'
    elif koopa_is_macos
    then
        dict[platform]='osx'
    fi
    dict[root]="${dict[prefix]}/libexec"
    dict[file]="${dict[name]}-${dict[version]}-${dict[platform]}-\
${dict[arch]}-bin"
    dict[url]="https://github.com/commercialhaskell/${dict[name]}/releases/\
download/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_cp "${dict[file]}" "${app[stack]}"
    unset -v STACK_ROOT
    koopa_rm "${HOME:?}/.stack"
    dict[gmp]="$(koopa_realpath "${dict[opt_prefix]}/gmp")"
    stack_args=(
        "--extra-include-dirs=${dict[gmp]}/include"
        "--extra-lib-dirs=${dict[gmp]}/lib"
        "--jobs=${dict[jobs]}"
        "--stack-root=${dict[root]}"
        '--verbose'
    )
    # > if koopa_is_linux
    # > then
    # >     dict[zlib]="$(koopa_realpath "${dict[opt_prefix]}/zlib")"
    # >     stack_args+=(
    # >         "--extra-include-dirs=${dict[zlib]}/include"
    # >         "--extra-lib-dirs=${dict[zlib]}/lib"
    # >     )
    # > fi
    "${app[stack]}" "${stack_args[@]}" setup
    # NOTE Can install a specific GHC version here with:
    # > app[stack]="${dict[prefix]}/bin/stack"
    # > koopa_assert_is_installed "${app[stack]}"
    # > "${app[stack]}" install 'ghc-9.0.2'
    return 0
}
