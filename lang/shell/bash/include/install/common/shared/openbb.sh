#!/usr/bin/env bash

# FIXME Installer is now hanging on my MacBook.

main() {
    # """
    # Install OpenBB terminal.
    # @note Updated 2022-11-16.
    #
    # @seealso
    # - https://github.com/OpenBB-finance/OpenBBTerminal/blob/main/
    #     openbb_terminal/README.md#anaconda--python
    # """
    local app dict
    declare -A app=(
        ['cat']="$(koopa_locate_cat --allow-system)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    declare -A dict=(
        ['conda_prefix']="$(koopa_anaconda_prefix)"
        ['name']='OpenBBTerminal'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['conda_prefix']}"
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
        "${dict['python_prefix']}"
    dict['env_file']='build/conda/conda-3-9-env.yaml'
    koopa_assert_is_file "${dict['env_file']}"
    koopa_activate_conda "${dict['conda_prefix']}"
    conda env create \
        --force \
        --file "${dict['env_file']}" \
        --prefix "${dict['env_prefix']}"
    conda activate "${dict['env_prefix']}"
    export PIP_REQUIRE_VIRTUALENV=false
    poetry install
    # > conda install --yes 'tensorflow'
    koopa_conda_deactivate
    koopa_cp ./* --target-directory="${dict['python_prefix']}"
    dict['bin_file']="${dict['prefix']}/bin/openbb"
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
