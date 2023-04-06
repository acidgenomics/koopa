#!/usr/bin/env bash

main() {
    # """
    # Install Visual Studio Code CLI.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://code.visualstudio.com/#alt-downloads
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/code-cli.rb
    # """
    local -A app dict
    local -a install_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'git' \
        'pkg-config' \
        'rust'
    app['cargo']="$(koopa_locate_cargo)"
    koopa_assert_is_executable "${app[@]}"
    dict['cargo_home']="$(koopa_init_dir 'cargo')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/microsoft/vscode/archive/refs/\
tags/${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/cli'
    export CARGO_HOME="${dict['cargo_home']}"
    export VSCODE_CLI_NAME_LONG='Code OSS'
    export VSCODE_CLI_VERSION="${dict['version']}"
    install_args=(
        '--config' 'net.git-fetch-with-cli=true'
        '--config' 'net.retry=5'
        '--jobs' "${dict['jobs']}"
        '--path' .
        '--root' "${dict['prefix']}"
        '--verbose'
    )
    koopa_print_env
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}
