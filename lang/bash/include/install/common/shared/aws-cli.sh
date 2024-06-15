#!/usr/bin/env bash

# FIXME Bootstrap is failing to link against system python correctly ugh.
# FIXME Returning library not loaded Python3
# https://stackoverflow.com/questions/49132419/python-on-macos-dyld-library-not-loaded-error

main() {
    # """
    # Install AWS CLI.
    # @note Updated 2024-06-15.
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
    app['python']="$(koopa_locate_python311 --allow-missing)"
    if [[ ! -x "${app['python']}" ]]
    then
        app['python']="$(koopa_locate_python311 --allow-bootstrap)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-download-deps'
    )
    koopa_python_create_venv \
        --prefix="${dict['libexec']}" \
        --python="${app['python']}"
    koopa_add_to_path_start "${dict['libexec']}/bin"
    export PIP_NO_CACHE_DIR=1
    dict['url']="https://github.com/aws/aws-cli/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    app['aws']="${dict['prefix']}/bin/aws"
    koopa_assert_is_exectuable "${app['aws']}"
    "${app['aws']}" --version
    return 0
}
