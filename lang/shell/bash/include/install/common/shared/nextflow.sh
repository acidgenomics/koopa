#!/usr/bin/env bash

# FIXME Rework this to install from https://get.nextflow.io, rather than using
# bioconda, which is often out of date.
# FIXME Can pin to our internal openjdk.
# FIXME OpenJDK > 18 is not currently supported.

main() {
    # """
    # Install Nextflow.
    # @note Updated 2022-12-15.
    #
    # @seealso
    # - https://github.com/nextflow-io/nextflow/
    # - https://get.nextflow.io/
    # - https://nextflow.io/releases/v${dict['version']}/nextflow
    # """
    local dict
    declare -A dict=(
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['script']='nextflow'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['openjdk']}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    koopa_download 'https://get.nextflow.io' "${dict['script']}"
    koopa_chmod +x "${dict['script']}"
    export NXF_HOME="${dict['prefix']}/libexec"
    export NXF_JAVA_HOME="${dict['openjdk']}"
    export NXF_VER="${dict['version']}"
    ."/${dict['script']}"
    koopa_cp --target-directory="${dict['libexec']}" "${dict['script']}"
    read -r -d '' "dict[bin_string]" << END || true
#!/bin/sh

export NXF_JAVA_HOME='${dict['openjdk']}'
'${dict['libexec']}/${dict['script']}' "\$@"
END
    koopa_write_string \
        --file="${dict['prefix']}/bin/nextflow" \
        --string="${dict['bin_string']}"
    koopa_chmod +x "${dict['prefix']}/bin/nextflow"
    return 0
}
