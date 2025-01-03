#!/usr/bin/env bash

main() {
    # """
    # Install rMATS.
    # @note Updated 2023-11-02.
    #
    # @seealso
    # - https://rmats.sourceforge.io/user_guide.htm
    # - https://github.com/Xinglab/rmats-turbo/issues/36
    # """
    local -A app dict
    koopa_assert_is_not_arm64
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    koopa_rm "${dict['prefix']}/bin"
    koopa_mkdir "${dict['prefix']}/bin"
    app['python']="${dict['prefix']}/libexec/bin/python3"
    app['rmats_py']="${dict['prefix']}/libexec/rMATS/rmats.py"
    koopa_assert_is_existing "${app[@]}"
    app['rmats']="${dict['prefix']}/bin/rmats"
    read -r -d '' "dict[rmats_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

# Ensure that STAR and other relevant conda binaries are in PATH.
PATH="\${PATH:-}"
PATH="${dict['prefix']}/libexec/bin:\${PATH}"
export PATH

${app['python']} \\
    ${app['rmats_py']} \\
    "\$@"
END
    koopa_write_string \
        --file="${app['rmats']}" \
        --string="${dict['rmats_string']}"
    koopa_chmod +x "${app['rmats']}"
    "${app['rmats']}" --help
    return 0
}
