#!/usr/bin/env bash

# FIXME This isn't working due to 2.7 version conflict between conda-forge
# and the hcc recipe...argh.

main() {
    # """
    # Install ADFR suite.
    # @note Updated 2022-10-19.
    # 
    # @seealso
    # - https://ccsb.scripps.edu/adfr/downloads/
    # - https://anaconda.org/HCC/adfr-suite
    # - https://github.com/nanome-ai/plugin-docking/blob/master/adfr-suite.yml
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-environments.html#sharing-an-environment
    # """
    local dict
    declare -A dict
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}/libexec"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}.yaml"
    read -r -d '' "dict[string]" << END || true
# > name: ${dict['name']}
channels:
  - hcc
  # > - conda-forge
  # > - anaconda
dependencies:
  # > - python=2.7.3
  - adfr-suite=${dict['version']}
  # > - numpy=1.15.0
prefix: ${dict['prefix']}
END
    koopa_write_string \
        --string="${dict['string']}" \
        --file="${dict['file']}"
    dict['file']="$(koopa_realpath "${dict['file']}")"
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='autodock-adfr' \
        -D "--file=${dict['file']}" \
        "$@"
}
