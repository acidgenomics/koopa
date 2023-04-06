#!/usr/bin/env bash

main() {
    # """
    # Install AWS CLI.
    # @note Updated 2023-03-22.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     getting-started-source-install.html
    # - https://github.com/aws/aws-cli/issues/6785
    # """
    local app conf_args dict
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['make']="$(koopa_locate_make --allow-system)"
    app['python']="$(koopa_locate_python311 --allow-missing)"
    # Allow edge case building against system Python, for system bootstrapping.
    if [[ ! -x "${app['python']}" ]]
    then
        app['python']='/usr/bin/python3'
        koopa_alert_note "Building against system Python at '${app['python']}'."
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/aws/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_python_create_venv \
        --prefix="${dict['libexec']}" \
        --python="${app['python']}"
    koopa_add_to_path_start "${dict['libexec']}/bin"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-download-deps'
    )
    export PIP_NO_CACHE_DIR=1
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
