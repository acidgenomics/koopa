#!/usr/bin/env bash

# NOTE This is currently failing to build on Ubuntu 20.

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2022-03-14.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    #
    # @seealso
    # - https://gist.github.com/jblachly/f8dc0f328d66659d9ee005548a5a2d2e
    # - https://sarahpenir.github.io/linux/Installing-bcl2fastq/
    # - https://github.com/rossigng/easybuild-easyconfigs/blob/main/
    #     easybuild/easyconfigs/b/bcl2fastq2/
    # - https://github.com/perllb/ctg-wgs/blob/master/
    #     container/ngs-tools-builder
    # - https://github.com/AlexsLemonade/alsf-scpca/blob/main/images/
    #     cellranger/install-bcl2fastq.sh
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_not_aarch64
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['installers_base']="$(koopa_private_installers_s3_uri)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='bcl2fastq'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['c_include_path']="/usr/include/${dict['arch']}-linux-gnu"
    koopa_assert_is_dir "${dict['c_include_path']}"
    export C_INCLUDE_PATH="${dict['c_include_path']}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['version']}.tar.zip"
    dict['url']="${dict['installers_base']}/${dict['name']}/src/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_extract "${dict['name']}${dict['maj_ver']}-"*"-Source.tar.gz"
    koopa_cd "${dict['name']}"
    koopa_mkdir "${dict['name']}-build"
    koopa_cd "${dict['name']}-build"
    koopa_print_env
    ../src/configure --prefix="${dict['prefix']}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    koopa_rm "${dict['prefix']}/bin/test"
    return 0
}
