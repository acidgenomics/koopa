#!/usr/bin/env bash

main() {
    # """
    # Install Apache Spark.
    # @note Updated 2023-06-12.
    #
    # Consider including 'JAVA_HOME' in our binary wrappers.
    #
    # @seealso
    # - https://spark.apache.org/downloads.html
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['url']="https://dlcdn.apache.org/spark/spark-${dict['version']}/\
spark-${dict['version']}-bin-hadoop${dict['maj_ver']}.tgz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['libexec']}"
    read -r -d '' "dict[pyspark_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

SPARK_HOME='${dict['libexec']}'
SPARK_HOME='\${SPARK_HOME}' '\${SPARK_HOME}/bin/pyspark' "\$@"
END
    read -r -d '' "dict[sparkr_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

SPARK_HOME='${dict['libexec']}'
SPARK_HOME='\${SPARK_HOME}' '\${SPARK_HOME}/bin/sparkR' "\$@"
END
    koopa_write_string \
        --file="${dict['prefix']}/bin/pyspark" \
        --string="${dict['pyspark_string']}"
    koopa_write_string \
        --file="${dict['prefix']}/bin/sparkR" \
        --string="${dict['sparkr_string']}"
    koopa_chmod +x "${dict['prefix']}/bin/pyspark"
    koopa_chmod +x "${dict['prefix']}/bin/sparkR"
    return 0
}
