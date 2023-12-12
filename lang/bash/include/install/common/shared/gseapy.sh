#!/usr/bin/env bash

main() {
    # """
    # Install GSEAPY.
    # @note Updated 2023-12-12.
    #
    # @seealso
    # - https://github.com/zqfang/gseapy/
    # - https://gseapy.readthedocs.io/
    # - https://bioconda.github.io/recipes/gseapy/README.html
    # """
    koopa_activate_app --build-only 'rust'
    koopa_install_python_package
    return 0
}
