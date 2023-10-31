#!/usr/bin/env bash

main() {
    # """
    # Install OpenBB terminal.
    # @note Updated 2023-10-31.
    #
    # This may error due to Little Snitch blocking on macOS.
    #
    # @seealso
    # - https://github.com/OpenBB-finance/OpenBBTerminal/blob/main/
    #     openbb_terminal/README.md#anaconda--python
    # - https://github.com/OpenBB-finance/OpenBBTerminal/blob/main/
    #     TROUBLESHOOT.md
    # - https://python-poetry.org/docs/configuration/
    # - https://github.com/conda/conda/issues/7741
    # """
    local -A app dict
    koopa_activate_ca_certificates
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['conda_env_prefix']="${dict['libexec']}/conda"
    dict['poetry_prefix']="${dict['libexec']}/poetry"
    dict['src_prefix']="${dict['libexec']}/openbb"
    koopa_mkdir \
        "${dict['conda_env_prefix']}" \
        "${dict['poetry_prefix']}" \
        "${dict['src_prefix']}"
    dict['conda_cache_prefix']="$(koopa_init_dir 'conda')"
    export CONDA_PKGS_DIRS="${dict['conda_cache_prefix']}"
    dict['url']="https://github.com/OpenBB-finance/OpenBBTerminal/archive/\
refs/tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    dict['conda_env_file']='build/conda/conda-3-10-env.yaml'
    koopa_assert_is_file "${dict['conda_env_file']}"
    export PIP_REQUIRE_VIRTUALENV=false
    koopa_print_env
    koopa_conda_create_env \
        --file="${dict['conda_env_file']}" \
        --prefix="${dict['conda_env_prefix']}"
    app['poetry']="${dict['conda_env_prefix']}/bin/poetry"
    koopa_assert_is_executable "${app['poetry']}"
    dict['poetry_config_file']='poetry.toml'
    koopa_assert_is_not_file "${dict['poetry_config_file']}"
    "${app['poetry']}" config \
        cache-dir "${dict['poetry_prefix']}" --local
    koopa_assert_is_file "${dict['poetry_config_file']}"
    "${app['poetry']}" config --list
    # Can use '-vvv' here for more verbose logging.
    "${app['poetry']}" install --no-interaction
    koopa_rm 'tests' 'website'
    koopa_cp ./* --target-directory="${dict['src_prefix']}"
    dict['poetry_venv_prefix']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['poetry_prefix']}/virtualenvs" \
            --type='d' \
    )"
    koopa_assert_is_dir "${dict['poetry_venv_prefix']}"
    app['poetry_python']="${dict['poetry_venv_prefix']}/bin/python3"
    koopa_assert_is_executable "${app['poetry_python']}"
    dict['terminal_py_file']="${dict['src_prefix']}/terminal.py"
    koopa_assert_is_file "${dict['terminal_py_file']}"
    dict['bin_file']="${dict['prefix']}/bin/openbb"
    read -r -d '' "dict[bin_string]" << END || true
#!/bin/sh
set -euo pipefail

main() {
    '${app['poetry_python']}' \\
        '${dict['terminal_py_file']}' "\$@"
    return 0
}

main "\$@"
END
    koopa_write_string \
        --file="${dict['bin_file']}" \
        --string="${dict['bin_string']}"
    koopa_chmod +x "${dict['bin_file']}"
    koopa_rm "${dict['poetry_prefix']}/cache"
    return 0
}
