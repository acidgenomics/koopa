#!/usr/bin/env bash

koopa::linux_install_openjdk() { # {{{1
    # """
    # Install OpenJDK.
    # @note Updated 2021-01-19.
    #
    # Don't early return if directory exists here.
    # We need to ensure alternatives code runs (see below).
    #
    # @seealso
    # - https://jdk.java.net/15/
    # - https://openjdk.java.net/
    # """
    local jdk_dir name name_fancy prefix reinstall tmp_dir unique version
    name='openjdk'
    name_fancy='OpenJDK'
    reinstall=0
    version=
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    jdk_dir="$(koopa::openjdk_prefix)"
    prefix="${jdk_dir}/${version}"
    [[ "$reinstall" -eq 1 ]] && koopa::sys_rm "$prefix"
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name_fancy" "$version" "$prefix"
    koopa::sys_mkdir "$jdk_dir"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        case "$version" in
            15.0.2)
                unique='0d1cfde4252546c6931946de8db48ee2/7'
                ;;
            15)
                unique='779bf45e88a44cbd9ea6621d33e33db1/36'
                ;;
            14.0.2)
                unique='205943a0976c4ed48cb16f1043c5c647/12'
                ;;
            14.0.1)
                unique='664493ef4a6946b186ff29eb326336a2/7'
                ;;
            14)
                unique='076bab302c7b4508975440c56f6cc26a/36'
                ;;
            13.0.2)
                unique='d4173c853231432d94f001e99d882ca7/8'
                ;;
            13.0.1)
                unique='cec27d702aa74d5a8630c65ae61e4305/9'
                ;;
            13)
                unique='5b8a42f3905b406298b72d750b6919f6/33'
                ;;
            *)
                koopa::stop "Unsupported version: '${version}'."
        esac
        file="${name}-${version}_linux-x64_bin.tar.gz"
        url="https://download.java.net/java/GA/jdk${version}/\
${unique}/GPL/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::mv "jdk-${version}" "$prefix"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    (
        koopa::cd "$jdk_dir"
        koopa::sys_ln "$version" 'latest'
    )
    koopa::sys_set_permissions -r "$jdk_dir"
    # This step will skip for non-shared install.
    koopa::linux_java_update_alternatives "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::linux_java_update_alternatives() { # {{{1
    # """
    # Update Java alternatives.
    # @note Updated 2020-07-05.
    #
    # This step is intentionally skipped for non-admin installs, when calling
    # from 'install-openjdk' script.
    # """
    local prefix priority
    koopa::assert_has_args_eq "$#" 1
    koopa::is_shared_install || return 0
    koopa::is_installed update-alternatives || return 0
    prefix="${1:?}"
    prefix="$(realpath "$prefix")"
    priority=100
    sudo rm -fv /var/lib/alternatives/java
    sudo update-alternatives --install \
        '/usr/bin/java' \
        'java' \
        "${prefix}/bin/java" \
        "$priority"
    sudo update-alternatives --set \
        'java' \
        "${prefix}/bin/java"
    sudo rm -fv /var/lib/alternatives/javac
    sudo update-alternatives --install \
        '/usr/bin/javac' \
        'javac' \
        "${prefix}/bin/javac" \
        "$priority"
    sudo update-alternatives --set \
        'javac' \
        "${prefix}/bin/javac"
    sudo rm -fv /var/lib/alternatives/jar
    sudo update-alternatives --install \
        '/usr/bin/jar' \
        'jar' \
        "${prefix}/bin/jar" \
        "$priority"
    sudo update-alternatives --set \
        'jar' \
        "${prefix}/bin/jar"
    update-alternatives --display java
    update-alternatives --display javac
    update-alternatives --display jar
    return 0
}
