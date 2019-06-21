#!/bin/sh

# Configuration functions.
# Modified 2019-06-21.



# Get R_HOME, rather than exporting as global variable.
# Modified 2019-06-20.
_koopa_find_r_home() {
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}



# Using unicode box drawings here.
# Note that we're truncating lines inside the box to 68 characters.
# Modified 2019-06-20.
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



# Used by `koopa info`.
# Modified 2019-06-20.
_koopa_locate() {
    local command
    local name
    local path
    
    command="$1"
    name="${2:-$command}"
    path="$(_koopa_quiet_which "$command")"
    
    if [[ -z "$path" ]]
    then
        path="[missing]"
    else
        path="$(realpath "$path")"
    fi
    printf "%s: %s" "$name" "$path"
}



# Get version stored internally in versions.txt file.
# Modified 2019-06-18.
_koopa_variable() {
    local what
    local file
    local match

    what="$1"
    file="${KOOPA_DIR}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}



# Update dynamic linker (LD) configuration.
# Modified 2019-06-19.
_koopa_update_ldconfig() {
    if [ -d /etc/ld.so.conf.d ]
    then
        sudo ln -fs \
            "${KOOPA_DIR}/system/config/etc/ld.so.conf.d/"*".conf" \
            /etc/ld.so.conf.d/.
        sudo ldconfig
    fi
}



# Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
# Modified 2019-06-20.
_koopa_update_profile() {
    _koopa_assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0
    
    local file="/etc/profile.d/koopa.sh"
    
    printf "Updating '%s'.\n" "$file"
    
    sudo mkdir -p "$(dirname file)"
    sudo rm -f "$file"

    sudo bash -c "cat << EOF > $file
#!/bin/sh

# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. ${KOOPA_DIR}/activate
EOF"
}



# Add shared R configuration symlinks in `${R_HOME}/etc`.
# Modified 2019-06-19.
_koopa_update_r_config() {
    local r_home

    _koopa_assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0

    printf "Updating '/etc/rstudio/'.\n"
    sudo mkdir -p /etc/rstudio
    sudo ln -fs \
        "${KOOPA_DIR}/system/config/etc/rstudio/"* \
        /etc/rstudio/.

    r_home="$(_koopa_find_r_home)"
    printf "Updating '%s'.\n" "$r_home"
    sudo ln -fs \
        "${KOOPA_DIR}/system/config/R/etc/"* \
        "${r_home}/etc/".

    # FIXME Switch this to a function.
    r-javareconf
}



# Update shell configuration.
# Modified 2019-06-21.
_koopa_update_shells() {
    _koopa_assert_has_sudo
    
    local shell
    shell="$1"
    shell="${KOOPA_BUILD_PREFIX}/bin/${shell}"
    
    local shell_file
    shell_file="/etc/shells"
        
    if ! grep -q "$shell" "$shell_file"
    then
        printf "Updating '%s' to include '%s'.\n" "$shell_file" "$shell"
        sudo sh -c "echo ${shell} >> ${shell_file}"
    fi
    
    printf "Run 'chsh -s %s %s' to change default shell.\n" "$shell" "$USER"
}



# Update XDG local configuration.
# ~/.config/koopa
# Modified 2019-06-21.
_koopa_update_xdg_config() {
    mkdir -p "$KOOPA_CONFIG_DIR"
    
    if [ ! -e "${KOOPA_CONFIG_DIR}/activate" ]
    then
        rm -f "${KOOPA_CONFIG_DIR}/activate"
        ln -s "${KOOPA_DIR}/activate" \
              "${KOOPA_CONFIG_DIR}/activate"
    fi

    if [ ! -e "${KOOPA_CONFIG_DIR}/dotfiles" ]
    then
        rm -f "${KOOPA_CONFIG_DIR}/dotfiles"
        ln -s "${KOOPA_DIR}/system/config/dotfiles" \
              "${KOOPA_CONFIG_DIR}/dotfiles"
    fi

    if [ ! -e "${KOOPA_CONFIG_DIR}/home" ]
    then
        rm -f "${KOOPA_CONFIG_DIR}/home"
        ln -s "${KOOPA_DIR}" \
              "${KOOPA_CONFIG_DIR}/home"
    fi
}
