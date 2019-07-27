#!/bin/sh
## shellcheck disable=SC2039



## Set JAVA_HOME environment variable.
##
## See also:
## - https://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
## - https://stackoverflow.com/questions/22290554
##
## Updated 2019-06-27.
_koopa_java_home() {
    local home
    local jvm_dir

    if [ -z "${JAVA_HOME:-}" ]
    then    
        if _koopa_is_darwin
        then
            home="$(/usr/libexec/java_home)"
        else
            jvm_dir="/usr/lib/jvm"
            if [ ! -d "$jvm_dir" ]
            then
                home=
            elif [ -d "${jvm_dir}/java-12-oracle" ]
            then
                home="${jvm_dir}/java-12-oracle"
            elif [ -d "${jvm_dir}/java-12" ]
            then
                home="${jvm_dir}/java-12"
            elif [ -d "${jvm_dir}/java" ]
            then
                home="${jvm_dir}/java"
            else
                home=
            fi
        fi
    else
        home="$JAVA_HOME"
    fi

    [ -d "$home" ] || return 0
    echo "$home"
}
