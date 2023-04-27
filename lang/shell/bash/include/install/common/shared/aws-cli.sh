#!/usr/bin/env bash

# FIXME Need to address this edge case on macOS:
#
# dyld[61266]: Library not loaded: @executable_path/../Python3
#  Referenced from: <68CB1594-35C5-3C88-A97A-504048CC29EC> /opt/koopa/app/aws-cli/2.11.13/lib/aws-cli/bin/python
#  Reason: tried: '/opt/koopa/app/aws-cli/2.11.13/lib/aws-cli/Python3' (no such file), '/System/Volumes/Preboot/Cryptexes/OS@executable_path/../Python3' (no such file), '/opt/koopa/app/aws-cli/2.11.13/lib/aws-cli/Python3' (no such file), '/usr/local/lib/Python3' (no such file), '/usr/lib/Python3' (no such file, not in dyld cache)

main() {
    # """
    # Install AWS CLI.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     getting-started-source-install.html
    # - https://github.com/aws/aws-cli/issues/6785
    # """
    local -A app dict
    local -a conf_args
    # FIXME This may be too lax, and can lead to the error commented above.
    app['python']="$(koopa_locate_python311 --allow-missing)"
    # Allow edge case building against system Python, for system bootstrapping.
    if [[ ! -x "${app['python']}" ]]
    then
        app['python']='/usr/bin/python3'
        koopa_alert_note "Building against system Python at '${app['python']}'."
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
    return 0
}
