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
    # - https://docs.haskellstack.org/en/stable/GUIDE/
    # - https://github.com/commercialhaskell/stack/issues/4408
    # """
    local app dict
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
    # FIXME Issues with lts-19.32 resolver:
    #     colourista not found
    #    - hadolint requires >=0
    #language-docker version 10.4.3 found
    #    - hadolint requires >=11.0.0 && <12
    #spdx not found
    #    - hadolint requires >=0
    #Using package flags:
    #    - hadolint: FlagName "static" = True
    # NOTE Can use '--omit-packages' to exclude mismatching packages.
    # https://www.stackage.org/lts-19.32
    case "${dict['version']}" in
        '2.11.'* | \
        '2.12.'*)
            "${app['stack']}" \
                --stack-root="${dict['stack_root']}" \
                --verbose \
                init \
                    --force \
                    --omit-packages \
                    --resolver 'nightly'
                    # --resolver 'lts-19.32'
            ;;
    esac
    "${app['stack']}" \
        --jobs="${dict['jobs']}" \
        --stack-root="${dict['stack_root']}" \
        --verbose \
        build
    "${app['stack']}" \
        --jobs="${dict['jobs']}" \
        --stack-root="${dict['stack_root']}" \
        --verbose \
        install \
            --local-bin-path="${dict['prefix']}/bin"
    return 0
}
