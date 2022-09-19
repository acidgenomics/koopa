#!/usr/bin/env bash

# FIXME Consider installing this into libexec...

main() {
    # """
    # Install Haskell GHCup.
    # @note Updated 2022-09-19.
    #
    # @seealso
    # - https://www.haskell.org/ghcup/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ghcup.rb
    # - https://gitlab.haskell.org/haskell/ghcup-hs/-/blob/master/scripts/
    #     bootstrap/bootstrap-haskell
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'curl'
    declare -A dict=(
        ['build_prefix']="$(koopa_init_dir 'build')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='ghcup-hs'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-v${dict['version']}.tar.bz2"
    dict['url']="https://gitlab.haskell.org/haskell/ghcup-hs/-/archive/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-v${dict['version']}"
    export BOOTSTRAP_HASKELL_CABAL_VERSION='recommended'
    export BOOTSTRAP_HASKELL_DOWNLOADER='curl'
    export BOOTSTRAP_HASKELL_GHC_VERSION='recommended'
    export BOOTSTRAP_HASKELL_INSTALL_HLS=1
    export BOOTSTRAP_HASKELL_INSTALL_STACK=1
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
