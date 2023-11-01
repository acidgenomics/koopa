#!/usr/bin/env bash

# FIXME 2.5.7 bundle currently won't install on macOS.

main() {
    # """
    # Install PyMOL.
    # @note Updated 2023-10-31.
    #
    # @seealso
    # - https://pymol.org/conda/
    # - https://pymol.org/installers/?C=M;O=D
    # - https://formulae.brew.sh/formula/pymol
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['conda_env_file']='conda.yaml'
    read -r -d '' "dict[conda_env_string]" << END || true
channels:
  - schrodinger
  - conda-forge
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
