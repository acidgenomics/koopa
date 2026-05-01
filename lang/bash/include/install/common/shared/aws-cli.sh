#!/usr/bin/env bash

install_from_conda() {
    _koopa_install_conda_package --name='awscli'
    return 0
}

install_from_source() {
    # """
    # Install AWS CLI.
    # @note Updated 2025-08-21.
    #
    # @seealso
    # - https://github.com/aws/aws-cli/tree/v2/
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     getting-started-source-install.html
    # - https://github.com/aws/aws-cli/issues/6785
    # - https://github.com/aws/aws-cli/discussions/8299/
    # """
    local -A app dict
    local -a conf_args
    app['python']="$(_koopa_locate_python --allow-missing)"
    if [[ ! -x "${app['python']}" ]]
    then
        app['python']="$(_koopa_locate_python --allow-bootstrap)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-download-deps'
    )
    _koopa_python_create_venv \
        --prefix="${dict['libexec']}" \
        --python="${app['python']}"
    _koopa_add_to_path_start "${dict['libexec']}/bin"
    export PIP_NO_CACHE_DIR=1
    dict['url']="https://github.com/aws/aws-cli/archive/refs/tags/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    app['aws']="${dict['prefix']}/bin/aws"
    _koopa_assert_is_executable "${app['aws']}"
    "${app['aws']}" --version
    return 0
}

main() {
    install_from_conda
    return 0
}
