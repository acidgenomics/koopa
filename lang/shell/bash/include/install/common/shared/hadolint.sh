#!/usr/bin/env bash

# FIXME Hitting this issue with hadolint 2.12.0:
# 2022-11-09 14:01:18.632683: [debug] Asking for a supported GHC version
# 2022-11-09 14:01:18.632763: [debug] Resolving package entries
# 2022-11-09 14:01:18.632814: [debug] Parsing the targets
# 2022-11-09 14:01:18.634837: [error] Error parsing targets: The specified targets matched no packages.
# Perhaps you need to run 'stack init'?

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-11-10.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # - https://www.stackage.org/
    # - https://docs.haskellstack.org/en/stable/GUIDE/
    # - https://github.com/commercialhaskell/stack/issues/4408
    # - Last working stack config:
    #   https://github.com/hadolint/hadolint/blob/v2.10.0/stack.yaml
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
    # This configuration is from hadolint 2.10.0.
    # https://github.com/hadolint/hadolint/tree/v2.10.0
    # Latest configuration is here:
    # https://github.com/hadolint/hadolint/blob/master/hadolint.cabal
    read -r -d '' "dict[stack_yaml_string]" << END || true
flags: {}
extra-package-dbs: []
packages:
  - .
resolver: nightly-2022-11-08
extra-deps:
  - ShellCheck-0.8.0
  - colourista-0.1.0.1
  - language-docker-11.0.0
  - spdx-1.0.0.2
  - hspec-2.9.4
  - hspec-core-2.9.4
  - hspec-discover-2.9.4
  - stm-2.5.0.2
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
