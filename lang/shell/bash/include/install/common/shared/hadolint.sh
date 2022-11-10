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
    read -r -d '' "dict[stack_yaml_string]" << END || true
flags: {}
extra-package-dbs: []
packages:
  - .
resolver: lts-19.32
extra-deps:
  - ShellCheck-0.8.0@sha256:353c9322847b661e4c6f7c83c2acf8e5c08b682fbe516c7d46c29605937543df,3297
  - colourista-0.1.0.1@sha256:98353ee0e2f5d97d2148513f084c1cd37dfda03e48aa9dd7a017c9d9c0ba710e,3307
  - language-docker-10.4.3@sha256:5a0b36c6a0051d0a69a9c29086e853702e5240765ae704b34eda0f1da8ee27cd,3810
  - spdx-1.0.0.2@sha256:7dfac9b454ff2da0abb7560f0ffbe00ae442dd5cb76e8be469f77e6988a70fed,2008
  - hspec-2.9.4@sha256:658a6a74d5a70c040edd6df2a12228c6d9e63082adaad1ed4d0438ad082a0ef3,1709
  - hspec-core-2.9.4@sha256:a126e9087409fef8dcafcd2f8656456527ac7bb163ed4d9cb3a57589042a5fe8,6498
  - hspec-discover-2.9.4@sha256:fbcf49ecfc3d4da53e797fd0275264cba776ffa324ee223e2a3f4ec2d2c9c4a6,2165
  - stm-2.5.0.2@sha256:e4dc6473faaa75fbd7eccab4e3ee1d651d75bb0e49946ef0b8b751ccde771a55,2314
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
