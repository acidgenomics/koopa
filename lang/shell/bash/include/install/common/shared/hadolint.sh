#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-11-10.
    #
    # @section Removal of 'stack.yaml' config in 2.11.0:
    # Manual 'stack.yaml' configuration is required for 2.11.0, 2.12.0.
    # Latest cabal configuration is here:
    # - https://github.com/hadolint/hadolint/blob/master/hadolint.cabal
    # Our current configuration is adapted from 2.10.0:
    # - https://github.com/hadolint/hadolint/tree/v2.10.0
    #
    # @section Hackage dependency info:
    # - https://hackage.haskell.org/package/ShellCheck
    # - https://hackage.haskell.org/package/colourista
    # - https://hackage.haskell.org/package/language-docker
    # - https://hackage.haskell.org/package/spdx
    # - https://hackage.haskell.org/package/hspec
    # - https://hackage.haskell.org/package/hspec-core
    # - https://hackage.haskell.org/package/hspec-discover
    # - https://hackage.haskell.org/package/stm
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # - https://docs.haskellstack.org/en/stable/GUIDE/
    # - https://hackage.haskell.org/
    # - https://www.stackage.org/
    # - https://github.com/commercialhaskell/stack/issues/4408
    # - Last working stack config:
    #   https://github.com/hadolint/hadolint/blob/v2.10.0/stack.yaml
    # - https://github.com/hadolint/hadolint/blob/master/.github/
    #     workflows/haskell.yml
    # - https://github.com/hadolint/hadolint/issues/899
    # - Stack configuration removal:
    #   https://github.com/hadolint/hadolint/commit/
    #     12473f0317f35fb685c19caaac8a253d187a99c9
    # """
    local app dict stack_args
    koopa_activate_app --build-only 'haskell-stack'
    declare -A app=(
        ['stack']="$(koopa_locate_stack)"
    )
    [[ -x "${app['stack']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='hadolint'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['stack_root']="$(koopa_init_dir 'stack')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    dict['stack_yaml_file']='stack.yaml'
    read -r -d '' "dict[stack_yaml_string]" << END || true
flags: {}
extra-package-dbs: []
packages:
  - .
# > resolver: nightly-2022-11-08  # ghc 9.2.4
resolver: lts-19.32  # ghc 9.0.2
extra-deps:
  - ShellCheck-0.8.0
  - colourista-0.1.0.1
  - language-docker-11.0.0
  - spdx-1.0.0.3
  - hspec-2.10.6
  - hspec-core-2.10.6
  - hspec-discover-2.10.6
  - stm-2.5.1.0
ghc-options:
  "\$everything": -haddock
END
    if [[ ! -f "${dict['stack_yaml_file']}" ]]
    then
        koopa_write_string \
            --file="${dict['stack_yaml_file']}" \
            --string="${dict['stack_yaml_string']}"
    fi
    koopa_assert_is_file "${dict['stack_yaml_file']}"
    stack_args=(
        "--jobs=${dict['jobs']}"
        "--stack-root=${dict['stack_root']}"
        '--verbose'
    )
    "${app['stack']}" "${stack_args[@]}" build
    "${app['stack']}" "${stack_args[@]}" install \
        --local-bin-path="${dict['prefix']}/bin"
    return 0
}
