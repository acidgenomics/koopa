#!/bin/sh
# shellcheck disable=SC2039



# Update dynamic linker (LD) configuration.
# Updated 2019-07-10.
_koopa_update_ldconfig() {
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_assert_is_installed ldconfig

    local os_type
    os_type="$(_koopa_os_type)"

    local conf_source
    conf_source="${KOOPA_HOME}/os/${os_type}/etc/ld.so.conf.d"
    
    if [ ! -d "$conf_source" ]
    then
        printf "ld.so.conf.d source files missing.\n%s\n" "$conf_source"
        return 1
    fi
    
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    printf "Updating ldconfig in '/etc/ld.so.conf.d/'.\n"
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done

    sudo ldconfig
}



# Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
# Updated 2019-06-29.
_koopa_update_profile() {
    local file
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    file="/etc/profile.d/koopa.sh"
    if [ -f "$file" ]
    then
        printf "Note: '%s' exists.\n" "$file"
        return 0
    fi
    printf "Adding '%s'.\n" "$file"
    sudo mkdir -p "$(dirname file)"
    sudo bash -c "cat << EOF > $file
#!/bin/sh

# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. ${KOOPA_HOME}/activate
EOF"
}



# Add shared R configuration symlinks in `${R_HOME}/etc`.
# Updated 2019-07-10.
_koopa_update_r_config() {
    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    
    local r_home
    r_home="$(_koopa_r_home)"

    # > local version
    # > version="$( \
    # >     R --version | \
    # >     head -n 1 | \
    # >     cut -d ' ' -f 3 | \
    # >     grep -Eo "^[0-9]+\.[0-9]+"
    # > )"

    printf "Updating '%s'.\n" "$r_home"

    local os_type
    os_type="$(_koopa_os_type)"

    local r_etc_source
    r_etc_source="${KOOPA_HOME}/os/${os_type}/etc/R"

    if [ ! -d "$r_etc_source" ]
    then
        printf "R etc config files files missing.\n%s\n" "$r_etc_source"
        return 1
    fi

    sudo ln -fns "${r_etc_source}/"* "${r_home}/etc/".

    printf "Creating site library.\n"
    site_library="${r_home}/site-library"
    sudo mkdir -p "$site_library"

    _koopa_build_set_permissions "$r_home"
    _koopa_r_javareconf
}



# Update shell configuration.
# Updated 2019-06-27.
_koopa_update_shells() {
    local shell
    local shell_file

    _koopa_assert_has_sudo
    
    shell="$(_koopa_build_prefix)/bin/${1}"
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
# Updated 2019-07-12.
_koopa_update_xdg_config() {
    local config_dir
    config_dir="$(_koopa_config_dir)"

    local home_dir
    home_dir="$(_koopa_home)"

    local os_type
    os_type="$(koopa os-type)"

    mkdir -p "$config_dir"

    relink() {
        local source_file
        source_file="$1"
        local dest_file
        dest_file="$2"
        if [ ! -e "$dest_file" ]
        then
            if [ ! -e "$source_file" ]
            then
                >&2 "Error: Source file missing.\n%s\n" "$source_file"
                return 1
            fi
            printf "Updating XDG config in %s.\n" "$config_dir"
            rm -fv "$dest_file"
            ln -fnsv "$source_file" "$dest_file"
        fi
    }

    relink "${home_dir}" "${config_dir}/home"
    relink "${home_dir}/activate" "${config_dir}/activate"
    relink "${home_dir}/os/${os_type}/etc/R" "${config_dir}/R"
}
