#!/bin/sh
# shellcheck disable=SC2039

# Configuration functions.
# Modified 2019-06-26.



# Modified 2019-06-25.
_koopa_is_remote() {
    [ -n "${SSH_CONNECTION:-}" ]
}



# Using unicode box drawings here.
# Note that we're truncating lines inside the box to 68 characters.
# Modified 2019-06-27.
_koopa_info_box() {
    local array
    local barpad

    array=("$@")
    barpad="$(printf "━%.0s" {1..70})"
    
    printf "\n  %s%s%s  \n"  "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n"  "${i::68}"
    done
    printf "  %s%s%s  \n\n"  "┗" "$barpad" "┛"
}



# Set JAVA_HOME environment variable.
#
# See also:
# - https://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
# - https://stackoverflow.com/questions/22290554
#
# Modified 2019-06-27.
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



# Get `R_HOME`, rather than exporting as global variable.
# Modified 2019-06-27.
_koopa_r_home() {
    _koopa_assert_is_installed R
    _koopa_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}



# Update rJava configuration.
# The default Java path differs depending on the system.
#
# > R CMD javareconf -h
#
# Environment variables that can be used to influence the detection:
#   JAVA           path to a Java interpreter executable
#                  By default first 'java' command found on the PATH
#                  is taken (unless JAVA_HOME is also specified).
#   JAVA_HOME      home of the Java environment. If not specified,
#                  it will be detected automatically from the Java
#                  interpreter.
#   JAVAC          path to a Java compiler
#   JAVAH          path to a Java header/stub generator
#   JAR            path to a Java archive tool
#
# Modified 2019-06-27.
_koopa_r_javareconf() {
    local java_home
    local java_flags
    local r_home

    _koopa_is_installed R || return 1
    _koopa_is_installed java || return 1
   
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    
    printf "Updating R Java configuration.\n"
    
    java_flags=(
        JAVA_HOME="${java_home}" \
        JAVA="${java_home}/bin/java" \
        JAVAC="${java_home}/bin/javac" \
        JAVAH="${java_home}/bin/javah" \
        JAR="${java_home}/bin/jar" \
    )

    r_home="$(_koopa_r_home)"
    _koopa_build_set_permissions "$r_home"
    
    R --vanilla CMD javareconf "${java_flags[@]}"

    if _koopa_has_sudo
    then
        sudo R --vanilla CMD javareconf "${java_flags[@]}"
    fi

    Rscript -e 'install.packages("rJava")'
}



# Update dynamic linker (LD) configuration.
# Modified 2019-06-23.
_koopa_update_ldconfig() {
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    
    if [ -d /etc/ld.so.conf.d ]
    then
        sudo ln -fs \
            "${KOOPA_HOME}/system/config/etc/ld.so.conf.d/"*".conf" \
            /etc/ld.so.conf.d/.
        sudo ldconfig
    fi
}



# Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
# Modified 2019-06-27.
_koopa_update_profile() {
    local file

    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0

    file="/etc/profile.d/koopa.sh"
    
    printf "Updating '%s'.\n" "$file"

    sudo mkdir -p "$(dirname file)"
    sudo rm -f "$file"
    
    sudo bash -c "cat << EOF > $file
#!/bin/sh

# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. ${KOOPA_HOME}/activate
EOF"
}



# Add shared R configuration symlinks in `${R_HOME}/etc`.
# Modified 2019-06-27.
_koopa_update_r_config() {
    local r_home

    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    
    r_home="$(_koopa_r_home)"

    printf "Updating '%s'.\n" "$r_home"
    
    sudo ln -fs \
        "${KOOPA_HOME}/system/config/R/etc/"* \
        "${r_home}/etc/".

    # This step appears to break RStudio Server.
    # > if _koopa_is_linux
    # > then
    # >     printf "Updating '/etc/rstudio/'.\n"
    # >     sudo mkdir -p /etc/rstudio
    # >     sudo ln -fs \
    # >         "${KOOPA_HOME}/system/config/etc/rstudio/"* \
    # >         /etc/rstudio/.
    # > fi

    _koopa_r_javareconf
}



# Update shell configuration.
# Modified 2019-06-27.
_koopa_update_shells() {
    local shell
    local shell_file

    _koopa_assert_has_sudo
    
    shell="$(koopa build-prefix)/bin/${1}"
    shell_file="/etc/shells"
        
    if ! grep -q "$shell" "$shell_file"
    then
        printf "Updating '%s' to include '%s'.\n" "$shell_file" "$shell"
        sudo sh -c "echo ${shell} >> ${shell_file}"
    fi
    
    printf "Run 'chsh -s %s %s' to change default shell.\n" "$shell" "$USER"
}



# Update XDG configuration.
# ~/.config/koopa
# Modified 2019-06-27.
_koopa_update_xdg_config() {
    local config_dir
    local home_dir

    config_dir="$(koopa config-dir)"
    home_dir="$(koopa home)"
    
    mkdir -p "$config_dir"
    
    if [ ! -e "${config_dir}/activate" ]
    then
        rm -f "${config_dir}/activate"
        ln -s "${home_dir}/activate" "${config_dir}/activate"
    fi

    if [ ! -e "${config_dir}/dotfiles" ]
    then
        rm -f "${config_dir}/dotfiles"
        ln -s "${home_dir}/system/config/dotfiles" "${config_dir}/dotfiles"
    fi

    if [ ! -e "${config_dir}/home" ]
    then
        rm -f "${config_dir}/home"
        ln -s "${home_dir}" "${config_dir}/home"
    fi

    if [ ! -e "${config_dir}/R" ]
    then
        rm -f "${config_dir}/R"
        ln -s "${home_dir}/system/config/R" "${config_dir}/R"
    fi
}
