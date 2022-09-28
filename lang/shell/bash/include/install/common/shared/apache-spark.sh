#!/usr/bin/env bash

main() {
    # """
    # Install Apache Spark.
    # @note Updated 2022-09-28.
    #
    # Consider including 'JAVA_HOME' in our binary wrappers.
    #
    # @seealso
    # - https://spark.apache.org/downloads.html
    # """
    local dict
    declare -A dict=(
        ['name']='spark'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="${dict['prefix']}/libexec"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}-bin-\
hadoop${dict['maj_ver']}.tgz"
    dict['url']="https://dlcdn.apache.org/${dict['name']}/\
${dict['name']}-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp \
        "${dict['name']}-${dict['version']}-bin-hadoop${dict['maj_ver']}" \
        "${dict['libexec']}"
    read -r -d '' "dict[pyspark_string]" << END || true
#!/bin/sh

SPARK_HOME='${dict['libexec']}'
SPARK_HOME='\${SPARK_HOME}' '\${SPARK_HOME}/bin/pyspark' "\$@"
END
    read -r -d '' "dict[sparkr_string]" << END || true
#!/bin/sh

SPARK_HOME='${dict['libexec']}'
SPARK_HOME='\${SPARK_HOME}' '\${SPARK_HOME}/bin/sparkR' "\$@"
END
    koopa_write_string \
        --file="${dict['prefix']}/bin/pyspark" \
        --string="${dict['pyspark_string']}"
    koopa_write_string \
        --file="${dict['prefix']}/bin/sparkR" \
        --string="${dict['sparkr_string']}"
    return 0
}
