#!/usr/bin/env bash

# FIXME Need to resolve CA certificates issue.
# Could not find a suitable TLS CA certificate bundle, invalid path: /opt/koopa/app/openbb/2.1.0/libexec/conda/lib/python3.9/site-packages/certifi/cacert.pem

main() {
    # """
    # Install OpenBB terminal.
    # @note Updated 2023-01-03.
    #
    # @seealso
    # - https://github.com/OpenBB-finance/OpenBBTerminal/blob/main/
    #     openbb_terminal/README.md#anaconda--python
    # - https://github.com/OpenBB-finance/OpenBBTerminal/blob/main/
    #     TROUBLESHOOT.md
    # - https://python-poetry.org/docs/configuration/
    # """
    local app dict
    koopa_activate_app 'ca-certificates'
    declare -A app
    app['cat']="$(koopa_locate_cat --allow-system)"
    [[ -x "${app['cat']}" ]] || return 1
    declare -A dict=(
        ['ca_certificates']="$(koopa_app_prefix 'ca-certificates')"
        ['conda_prefix']="$(koopa_conda_prefix)"
        ['name']='OpenBBTerminal'
        ['poetry_cache_dir']='poetry/cache'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['ca_certificates']}" \
        "${dict['conda_prefix']}"
    dict['cacert']="${dict['ca_certificates']}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict['cacert']}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['env_prefix']="${dict['libexec']}/conda"
    dict['python_prefix']="${dict['libexec']}/python"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/OpenBB-finance/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir \
        "${dict['env_prefix']}" \
        "${dict['poetry_cache_dir']}" \
        "${dict['python_prefix']}"
    dict['env_file']='build/conda/conda-3-9-env.yaml'
    koopa_assert_is_file "${dict['env_file']}"
    koopa_activate_conda "${dict['conda_prefix']}"
    conda env create \
        --force \
        --file "${dict['env_file']}" \
        --prefix "${dict['env_prefix']}"
    app['poetry']="${dict['env_prefix']}/bin/poetry"
    [[ -x "${app['poetry']}" ]] || return 1
    conda activate "${dict['env_prefix']}"
    export DEFAULT_CA_BUNDLE_PATH="${dict['cacert']}"
    export PIP_REQUIRE_VIRTUALENV=false
    export POETRY_CACHE_DIR="${dict['poetry_cache_dir']}"
    # poetry 1.1.13 doesn't support '--no-cache'.
    # This step may error due to Little Snitch blocking rule on macOS.
    "${app['poetry']}" install --no-interaction --verbose
    # > conda install --yes 'tensorflow'
    koopa_conda_deactivate
    koopa_cp ./* --target-directory="${dict['python_prefix']}"
    dict['bin_file']="${dict['prefix']}/bin/openbb"
    # FIXME Rework using koopa_write_string'...
    koopa_touch "${dict['bin_file']}"
    "${app['cat']}" > "${dict['bin_file']}" << END
#!/bin/sh
set -euo pipefail

SCRIPT_PATH="\$(readlink -f "\$0")"
PREFIX="\$(cd -- "\$(dirname -- "\$SCRIPT_PATH")/.." && pwd)"

main() {
    "\${PREFIX}/libexec/conda/bin/python3" \
        "\${PREFIX}/libexec/python/terminal.py"
    return 0
}

main "\$@"
END
    koopa_chmod +x "${dict['bin_file']}"
    return 0
}
