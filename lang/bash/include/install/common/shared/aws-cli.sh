#!/usr/bin/env bash

# FIXME We need to improve linkage to openssl3 here, otherwise seeing
# library linkage error on Ubuntu 22.
#
# FIXME Including openssl3 here still isn't fixing linkage issue...this may
# be an open problem with aws-cli

main() {
    # """
    # Install AWS CLI.
    # @note Updated 2024-07-02.
    #
    # @seealso
    # - https://github.com/aws/aws-cli/tree/v2/
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     getting-started-source-install.html
    # - https://github.com/aws/aws-cli/issues/6785
    # - https://github.com/aws/aws-cli/discussions/8299/
    # """
    local -A app dict
    local -a conf_args deps
    # Need to include this, otherwise we hit ssl linkage issues on Ubuntu.
    deps+=('openssl3')
    koopa_activate_app "${deps[@]}"
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
    koopa_assert_is_executable "${app['aws']}"
    "${app['aws']}" --version
    return 0
}
