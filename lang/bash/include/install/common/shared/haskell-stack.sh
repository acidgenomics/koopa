#!/usr/bin/env bash

main() {
    # """
    # Install Haskell Stack.
    # @note Updated 2026-01-09.
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
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     haskell-stack.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ghc@9.rb
    # - https://www.haskell.org/ghc/blog/20200515-ghc-on-arm.html
    # - https://github.com/commercialhaskell/stack/issues/5617
    # - GHCup may help with install support on ARM.
    #   https://github.com/haskell/ghcup-metadata/blob/master/ghcup-0.0.7.yaml
    # """
    local -A app dict
    local -a stack_args
    dict['arch']="$(koopa_arch)" # e.g. 'x86_64'.
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    app['stack']="${dict['prefix']}/bin/stack"
    case "${dict['arch']}" in
        'arm64')
            dict['arch']='aarch64'
            ;;
    esac
    if koopa_is_linux
    then
        dict['platform']='linux'
    elif koopa_is_macos
    then
        dict['platform']='osx'
    fi
    dict['root']="${dict['prefix']}/libexec"
    dict['url']="https://github.com/commercialhaskell/stack/releases/download/\
v${dict['version']}/stack-${dict['version']}-${dict['platform']}-\
${dict['arch']}-bin"
    koopa_download "${dict['url']}" "${app['stack']}"
    koopa_chmod 'u+x' "${app['stack']}"
    stack_args=(
        "--jobs=${dict['jobs']}"
        "--stack-root=${dict['root']}"
        '--verbose'
    )
    "${app['stack']}" "${stack_args[@]}" setup
    return 0
}
