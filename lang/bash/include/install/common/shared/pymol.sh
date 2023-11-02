#!/usr/bin/env bash

main() {
    # """
    # Install PyMOL.
    # @note Updated 2023-11-02.
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
    koopa_print_env
    koopa_conda_create_env \
        --file="${dict['conda_env_file']}" \
        --prefix="${dict['libexec']}"
    koopa_mkdir "${dict['prefix']}/bin"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/bin/pymol' 'pymol'
    )
    return 0
}
