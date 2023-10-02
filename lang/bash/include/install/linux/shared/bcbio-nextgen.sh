#!/usr/bin/env bash

main() {
    # """
    # Install bcbio-nextgen.
    # @note Updated 2023-03-27.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    #
    # STAR isn't working reliably in 1.2.9 due to stdin handoff to samtools
    # sort. HISAT2 does not have this problem.
    #
    # @seealso
    # - bcbio_nextgen.py upgrade --help
    # - https://bcbio-nextgen.readthedocs.io/en/latest/contents/
    #     installation.html
    # - samtools install issue (libcrypto.so.1.0.0):
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3632
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3557
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3318
    #   - https://github.com/PacificBiosciences/pbbioconda/issues/85
    #   - https://github.com/bioconda/bioconda-recipes/issues/13958
    # """
    local -A app dict
    local -a install_args
    koopa_activate_app --build-only 'bzip2' 'python3.11'
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['install_dir']="${dict['prefix']}/libexec"
    dict['tools_dir']="${dict['prefix']}"
    dict['file']='bcbio_nextgen_install.py'
    dict['url']="https://raw.github.com/bcbio/bcbio-nextgen/master/\
scripts/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_mkdir "${dict['prefix']}"
    install_args=(
        "${dict['install_dir']}"
        '--datatarget' 'rnaseq'
        '--isolate'
        '--mamba'
        '--nodata'
        '--tooldir' "${dict['tools_dir']}"
        '--upgrade' 'stable'
    )
    koopa_activate_ca_certificates
    koopa_print_env
    koopa_dl 'Install args' "${install_args[*]}"
    "${app['python']}" "${dict['file']}" "${install_args[@]}"
    app['conda']="${dict['install_dir']}/anaconda/bin/conda"
    koopa_assert_is_installed "${app['conda']}"
    "${app['conda']}" clean --yes --tarballs
    return 0
}
