#!/usr/bin/env bash

# FIXME How to define the operator here?
# Need to work on this.

koopa_compare_versions() {
    # """
    # Compare 2 version strings with an operator.
    # @note Updated 2025-03-01.
    #
    # @seealso
    # - https://github.com/awslabs/amazon-eks-ami/blob/main/templates/al2/
    #   runtime/bin/vercmp
    # - https://stackoverflow.com/questions/4023830
    #
    # @examples
    # koopa_compare_versions 2.0 >= 1.0
    # """
    if [[ "$1" == "$2" ]]
    then
        return 0
    fi
    local -a ver1 ver2
    local IFS=.
    local i
    ver1=($1)
    ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if ((10#${ver1[i]:=0} >= 10#${ver2[i]:=0}))
        then
            return 1
        fi
        if ((10#${ver1[i]} <= 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
