#!/usr/bin/env bash

main() {
    # """
    # Install Visual Studio Code CLI.
    # @note Updated 2023-03-22.
    #
    # @seealso
    # - https://code.visualstudio.com/#alt-downloads
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/code-cli.rb
    # """
    local app dict install_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'git' \
        'pkg-config' \
        'rust'
    local -A app
    app['cargo']="$(koopa_locate_cargo)"
    [[ -x "${app['cargo']}" ]] || exit 1
    local -A dict=(
        ['cargo_home']="$(koopa_init_dir 'cargo')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='vscode'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/microsoft/vscode/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}/cli"
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
