#!/usr/bin/env bash

main() {
    # """
    # Install Haskell GHCup.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://www.haskell.org/ghcup/
    # - https://github.com/haskell/ghcup-hs
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ghcup.rb
    # - https://github.com/haskell/ghcup-hs/blob/master/scripts/
    #     bootstrap/bootstrap-haskell
    # """
    local -A dict
    koopa_activate_app --build-only 'curl'
    dict['build_prefix']="$(koopa_init_dir 'build')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/haskell/ghcup-hs/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # > export BOOTSTRAP_HASKELL_CABAL_VERSION='recommended'
    # > export BOOTSTRAP_HASKELL_GHC_VERSION='recommended'
    # > export BOOTSTRAP_HASKELL_INSTALL_HLS=1
    # > export BOOTSTRAP_HASKELL_INSTALL_STACK=1
    export BOOTSTRAP_HASKELL_DOWNLOADER='curl'
    export BOOTSTRAP_HASKELL_MINIMAL=1
    export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
    export BOOTSTRAP_HASKELL_NO_UPGRADE=1
    export BOOTSTRAP_HASKELL_VERBOSE=1
    export GHCUP_INSTALL_BASE_PREFIX="${dict['build_prefix']}"
    export PATH="${dict['build_prefix']}/.ghcup/bin:${PATH:-}"
    koopa_print_env
    dict['bootstrap']='scripts/bootstrap/bootstrap-haskell'
    koopa_assert_is_file "${dict['bootstrap']}"
    "${dict['bootstrap']}"
    koopa_cp "${dict['build_prefix']}/.ghcup" "${dict['prefix']}/libexec"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
