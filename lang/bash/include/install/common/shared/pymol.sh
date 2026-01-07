#!/usr/bin/env bash

main() {
    # """
    # Install PyMOL.
    # @note Updated 2026-01-05.
    #
    # @seealso
    # - https://pymol.org/conda/
    # - https://pymol.org/installers/?C=M;O=D
    # - https://formulae.brew.sh/formula/pymol
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-channels.html
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['conda_env_file']='conda.yaml'
    read -r -d '' "dict[conda_env_string]" << END || true
channels:
  - conda-forge
  - schrodinger
dependencies:
  - pymol-bundle =${dict['version']}
  - pyqt
END
    koopa_write_string \
        --file="${dict['conda_env_file']}" \
        --string="${dict['conda_env_string']}"
    koopa_install_conda_package --file="${dict['conda_env_file']}"
    return 0
}
