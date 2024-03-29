#!/usr/bin/env bash

main() {
    # """
    # Install STAR from bioconda.
    # @note Updated 2023-10-17.
    # """
    local -A app dict
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    if koopa_is_linux
    then
        dict['patch_file']='patch-script-dir.patch'
        read -r -d '' "dict[patch_string]" << END || true
--- STAR
+++ STAR-1
@@ -1,6 +1,6 @@
 #!/bin/bash

-SCRIPT_DIR=\$( cd -- "\$( dirname -- "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
+SCRIPT_DIR=${dict['prefix']}/bin
 DIR=\$SCRIPT_DIR
 BASE=\${DIR}/\$(basename "\$0")
 CMDARGS="\$@"
END
        koopa_write_string \
            --file="${dict['patch_file']}" \
            --string="${dict['patch_string']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STAR" \
            "${dict['patch_file']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STARlong" \
            "${dict['patch_file']}"
    fi
    "${dict['prefix']}/bin/STAR" -h
    return 0
}
