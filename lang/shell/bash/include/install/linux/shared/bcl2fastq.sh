#!/usr/bin/env bash

# NOTE Currently failing to install on Ubuntu 20:
# ## include could not find load file:
# ## CMakeFindDependencyMacro
# ## Unknown CMake command "find_dependency".

# FIXME Consider using this guide to incorporate build fixes:
# https://gist.github.com/jblachly/f8dc0f328d66659d9ee005548a5a2d2e

# # 1. Make sure `configure` can find `sys/stat.h`:
#
# Modify `bcl2fastq/src/cmake/macros.cmake`
#
# Find the last block:
# ```
# #
# # Macro to find libraries, with support for static-only search
# #
# macro(bcl2fastq_find_header_or_die variable file)
# find_file(${variable} ${file} HINTS ENV C_INCLUDE_PATH ENV CPATH ENV CPLUS_INCLUDE_PATH)
# if    (${variable})
#     message(STATUS "${file} found as ${${variable}}")
# else  (${variable})
#     message(FATAL_ERROR "Required header ${file} not found.")
# endif (${variable})
# endmacro(bcl2fastq_find_header_or_die)
# ```
#
# And change the `find_file` function to include `/usr/include/x86_64-linux-gnu/` (the location of `sys/` in Ubuntu on amd64) thusly:
#
# `find_file(${variable} ${file} HINTS ENV C_INCLUDE_PATH ENV CPATH ENV CPLUS_INCLUDE_PATH PATHS /usr/include/x86_64-linux-gnu/)`
#
# # 2. Fix the source code to work with newer Boost versions
#
# bcl2fastq/src/cxx/lib/io/Xml.cpp
# modify lines 172 and 180 to include the correct template:
#
# `boost::property_tree::write_xml(os, treeWithIndexAttributes, boost::property_tree::xml_writer_make_settings(' '    , 2));`
#
# to
#
# `boost::property_tree::write_xml(os, treeWithIndexAttributes, boost::property_tree::xml_writer_make_settings<ptree::key_type>(' '    , 2));`
#
# and likewise again on line 180
#
# _Explanation:_
# Boost versions >= 1.56 changed the definition of the xml_writer_make_settings function template:
# http://www.boost.org/doc/libs/1_44_0/boost/property_tree/detail/xml_parser_writer_settings.hpp
# http://www.boost.org/doc/libs/1_58_0/boost/property_tree/detail/xml_parser_writer_settings.hpp

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
    # """
    local app dict
    koopa_assert_has_no_args "$#"
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
        ['platform']='linux-gnu'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    # FIXME Error if this PATH is missing on current machine.
    # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
    export C_INCLUDE_PATH="/usr/include/${dict['arch']}-${dict['platform']}"
    koopa_print_env
    ../src/configure --prefix="${dict['prefix']}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    koopa_rm "${dict['prefix']}/bin/test"
    return 0
}
