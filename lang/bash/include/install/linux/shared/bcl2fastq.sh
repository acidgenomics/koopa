#!/usr/bin/env bash

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2023-05-23.
    #
    # ARM is not yet supported.
    #
    # @seealso
    # Conda approach:
    # - https://anaconda.org/dranew/bcl2fastq/files
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-environments.html
    #
    # Building from source (problematic with newer GCC / clang):
    # - https://gist.github.com/jblachly/f8dc0f328d66659d9ee005548a5a2d2e
    # - https://sarahpenir.github.io/linux/Installing-bcl2fastq/
    # - https://github.com/rossigng/easybuild-easyconfigs/blob/main/
    #     easybuild/easyconfigs/b/bcl2fastq2/
    # - https://github.com/perllb/ctg-wgs/blob/master/
    #     container/ngs-tools-builder
    # - https://github.com/AlexsLemonade/alsf-scpca/blob/main/images/
    #     cellranger/install-bcl2fastq.sh
    # - Potential method for disabling ICU in Boost build (if necessary):
    #   https://stackoverflow.com/questions/31138251/building-boost-without-icu
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['conda_file']='conda.yaml'
    read -r -d '' "dict[conda_string]" << END || true
name: bcl2fastq
dependencies:
    - boost=1.60.0  # 1.54.0
    - bzip2  # 1.0.6
    - cloog  # 0.18.0
    - cmake # 3.6.2 / 3.6.3
    - curl  # 7.52.1
    - expat  # 2.1.0
    - gcc=8.5.0  # 4.8.5
    - gmp  # 6.1.0
    - isl  # 0.16.1 / 0.12.2
    - mpc  # 1.0.3
    - mpfr  # 3.1.5
    - ncurses  # 5.9
    - openssl  # 1.0.2l
    - xz  # 5.2.2
    - zlib  # 1.2.8
END
    koopa_write_string \
        --file="${dict['conda_file']}" \
        --string="${dict['conda_string']}"
    koopa_conda_create_env \
        --file="${dict['conda_file']}" \
        --prefix="${dict['libexec']}"
    dict['url']="${dict['installers_base']}/bcl2fastq/src/\
${dict['version']}.tar.zip"
    "${app['aws']}" --profile='acidgenomics' s3 cp \
        "${dict['url']}" "$(koopa_basename "${dict['url']}")"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'unzip'
    koopa_extract 'unzip/'*'.tar.gz' 'src'
    koopa_mkdir 'build'
    (
        koopa_cd 'build'
        # FIXME Need to activate conda here.
        # FIXME Consider reworking 'koopa_conda_activate_env' here or something
        # of the sort.
        ../src/configure --prefix="${dict['prefix']}"
        make
        make install
    )
    return 0
}
