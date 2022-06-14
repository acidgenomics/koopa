#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-06-14.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # """
    local app dict stack_args
    declare -A app=(
        [stack]="$(koopa_locate_stack)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='hadolint'
        [stack_root]="$(koopa_init_dir 'stack')"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    stack_args=(
        "--jobs=${dict[jobs]}"
        "--stack-root=${dict[stack_root]}"
        # > '--no-install-ghc'
        # > '--skip-ghc-check'
        # > '--system-ghc'
    )
    # > export STACK_ROOT="${dict[stack_root]}"
    # > koopa_rm "${HOME:?}/.stack"
    # > "${app[stack]}" config set system-ghc --global true
    "${app[stack]}" "${stack_args[@]}" build
    "${app[stack]}" "${stack_args[@]}" \
        --local-bin-path="${dict[prefix]}/bin" \
        install
    return 0
}
